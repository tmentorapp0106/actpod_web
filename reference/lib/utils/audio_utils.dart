import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/log.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class AudioUtils {
  static Future<String> downloadAudioFile(String url) async {
    try {
      final innerUrl = url.split("http").last; // get everything after first "http"
      final cleanedUrl = "http$innerUrl"; // prepend "http"
      final innerUri = Uri.parse(cleanedUrl);

      // Use the last segment of the inner URL as file name
      String audioFileName = innerUri.pathSegments.last.split("?").first.split("/").last;
      final response = await http.get(Uri.parse(url));

      // Check if the response is successful
      if (response.statusCode != 200) {
        throw Exception("Failed to download audio: ${response.statusCode}");
      }

      // Ensure the Content-Type is audio/m4a
      String? contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('audio')) {
        throw Exception("Invalid MIME type: $contentType");
      }

      // Get the application documents directory
      final dir = await getTemporaryDirectory();
      final intermediateFolder = Directory('${dir.path}/intermediate'); // Specify folder name
      if (!(await intermediateFolder.exists())) {
        await intermediateFolder.create(recursive: true);  // Create the folder
      }
      final filePath = '${dir.path}/intermediate/$audioFileName';
      final file = File(filePath);

      // Write file
      await file.writeAsBytes(response.bodyBytes, flush: true);
      return filePath;
    } catch (e) {
      print("Error downloading audio: $e");
      rethrow;
    }
  }

  static Future<String> downloadAudioFileWithProgress(
      String url, {
        required void Function(double progress) onProgress,
      }) async {
    final client = http.Client();
    try {
      Uri? original;
      Uri? decoded;

      // Build candidates
      try {
        original = Uri.parse(url.trim());
        if (!original.hasScheme && (url.startsWith('http%3A') || url.startsWith('https%3A'))) {
          // Likely percent-encoded; leave original null so we try decoded first
          original = null;
        }
        if (original != null && !original.hasScheme) {
          original = Uri.parse('https://${original.toString()}');
        }
      } catch (_) {}

      try {
        final d = Uri.decodeFull(url.trim());
        decoded = Uri.parse(d);
        if (!decoded.hasScheme) decoded = Uri.parse('https://${decoded.toString()}');
      } catch (_) {}

      // Choose order: if we detected a percent-encoded scheme, try decoded first; else try original first.
      final candidates = <Uri>[
        if (original != null) original,
        if (decoded != null && (original == null || decoded.toString() != original.toString())) decoded!,
      ];
      if (candidates.isEmpty) {
        throw Exception('Invalid URL');
      }

      http.StreamedResponse? res;
      Uri? finalUri;
      // Try candidates until one returns 200
      for (final u in candidates) {
        final req = http.Request('GET', u)
          ..followRedirects = true
          ..maxRedirects = 5
          ..headers.addAll({
            'Accept': '*/*',
            'User-Agent': 'ActPod/1.0 (Flutter; dart:io)',
          });

        final tryRes = await client.send(req);
        if (tryRes.statusCode == 200) {
          res = tryRes;
          finalUri = u;
          break;
        } else if (tryRes.isRedirect) {
          // package:http + dart:io usually follows redirects when followRedirects=true,
          // but if a server uses 302 with odd headers, we might still land here.
          // Let’s still accept the stream if we ended at 200.
        } else {
          // If first candidate fails (e.g., 404), try the next one.
          await tryRes.stream.drain();
        }
      }

      if (res == null || res.statusCode != 200) {
        throw Exception('Failed to download audio: ${res?.statusCode ?? 'unknown'}');
      }

      // Decide filename
      final uri = finalUri!;
      String fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last.split('?').first.split("/").last : '';
      if (fileName.isEmpty || fileName == '/') fileName = '${const Uuid().v4()}.mp3';
      if (p.extension(fileName).isEmpty) fileName = '$fileName.mp3';

      final dir = await getTemporaryDirectory();
      final intermediate = Directory(p.join(dir.path, 'intermediate'));
      if (!await intermediate.exists()) await intermediate.create(recursive: true);
      final filePath = p.join(intermediate.path, fileName);

      final out = File(filePath).openWrite();

      final total = res.contentLength; // may be null
      int received = 0;

      await for (final chunk in res.stream) {
        received += chunk.length;
        out.add(chunk);
        if (total == null || total == 0) {
          // Unknown total → show a “growing” indicator (optional: map to 0.0..0.9)
          onProgress((received % (1024 * 1024)) / (1024 * 1024)); // cycles 0..1
        } else {
          onProgress(received / total);
        }
      }

      await out.flush();
      await out.close();

      // Snap to 100% if we knew the total
      if (total != null && received >= total) onProgress(1.0);

      return filePath;
    } finally {
      client.close();
    }
  }

  static Future<Duration?> getAudioFileLength(String filePath) async {
    final audioPlayer = AudioPlayer();
    try {
      // Set the local file path as the audio source
      await audioPlayer.setSourceDeviceFile(filePath);

      // Fetch the duration
      final duration = await audioPlayer.getDuration();
      return duration;
    } catch (e) {
      print('Error fetching audio duration: $e');
      return null;
    } finally {
      // Dispose of the player to free resources
      await audioPlayer.dispose();
    }
  }

  static Future<Duration?> getAudioUrlLength(String url) async {
    AudioPlayer audioPlayer = AudioPlayer();
    try {
      // Set the URL
      await audioPlayer.setSourceUrl(url);

      // Fetch the duration
      final duration = await audioPlayer.getDuration();
      return duration;
    } catch (e) {
      print('Error fetching audio duration: $e');
      return null;
    } finally {
      // Dispose of the audio player
      await audioPlayer.dispose();
    }
  }

  static Future<String?> concatAudiosSync(
      List<String> filePaths,
      ) async {
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    String outputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.wav';
    String listFilePath = '${appDirectory.path}/intermediate/concat_list.txt';

    // Step 1: Create concat list file
    File listFile = File(listFilePath);
    String fileListContent = filePaths.map((path) => "file '$path'").join('\n');
    await listFile.writeAsString(fileListContent);

    // Step 2: Concatenate re-encoded files
    final concatSession = await FFmpegKit.execute(
      '-f concat -safe 0 -i "$listFilePath" -c copy "$outputPath"'
    );

    final concatReturnCode = await concatSession.getReturnCode();
    if (!ReturnCode.isSuccess(concatReturnCode)) {
      return null;
    }

    return outputPath;
  }

  static Future<double> getDurationSeconds(String filePath) async {
    // Use FFprobe to get duration. This implementation is conceptual,
    // you may need to adjust it based on your actual FFprobeKit wrapper.
    final session = await FFprobeKit.getMediaInformation(filePath);
    final info = session.getMediaInformation();
    final duration = info?.getDuration(); // Duration is usually returned as a string or double in seconds.

    // Assuming getDuration() returns a string that needs to be parsed (e.g., "15.432")
    if (duration != null) {
      return double.tryParse(duration) ?? 0.0;
    }
    return 0.0;
  }

  static Future<String?> concatAudiosSimple(
      List<String> filePaths,
      Function(String outputPath) onSuccess,
      Function() onFailed,
      Function(double progress) onProgress,
      ) async {
    // We no longer need fadeDurationMs or chunking logic

    // --- Step 1: Setup ---
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate');
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);
    }
    // Final output is MP3
    String finalOutputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.mp3';

    // --- Step 2: Create list file for concatenation (Uses all filePaths directly) ---
    String listFilePath = '${appDirectory.path}/intermediate/${const Uuid().v1()}_list.txt';
    File listFile = File(listFilePath);

    // The list file content directly references the original input file paths
    String fileListContent = filePaths
        .map((path) => "file '$path'")
        .join('\n');
    await listFile.writeAsString(fileListContent);

    // --- Step 3: Execute final concatenation (using -f concat -c copy) ---
    // This is the fastest, simplest way to join MP3 files without re-encoding.
    String concatCmd =
        '-f concat -safe 0 -i "$listFilePath" -c copy -y "$finalOutputPath"';

    await FFmpegKit.executeAsync(
      concatCmd,
          (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          // Success callback
          onSuccess(finalOutputPath);
        } else {
          // Failure callback
          if (kDebugMode) {
            print("FFmpeg Simple Concat Failed. Command: $concatCmd");
            print("Error: ${await session.getOutput()}");
          }
          onFailed();
        }
      },
          (log) => print(log.getMessage()),
      // Progress tracking might be less accurate for -c copy, but we keep the handler
          (stats) => onProgress(stats.getTime().toDouble() * 0.003),
    );

    return finalOutputPath;
  }

  static Future<String?> concatAudiosWithFadeSingleCommand(
      List<String> filePaths,
      int fadeDurationMs, // Represents the duration of the fade-out and fade-in
      Function(String outputPath) onSuccess,
      Function() onFailed,
      Function(double progress) onProgress,
      ) async {
    final double fadeDurationSec = fadeDurationMs / 1000.0;

    // --- Step 1: Setup ---
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate');
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);
    }
    String finalOutputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.mp3';

    // A. Get durations for all files
    List<double> fileDurations = [];
    for (String path in filePaths) {
      fileDurations.add(await getDurationSeconds(path));
    }

    if (filePaths.length < 2) {
      // If there's only one file, no concatenation or fading is needed.
      await File(filePaths.first).copy(finalOutputPath);
      onSuccess(finalOutputPath);
      return finalOutputPath;
    }

    // B. Build the FFmpeg Command
    List<String> inputs = []; // -i "file..."
    List<String> filters = []; // [filter1];[filter2];...
    List<String> concatInputs = []; // [a0_final][a1_final]... for the concat filter

    for (int j = 0; j < filePaths.length; j++) {
      final String inputLabel = '[${j}:a]';
      inputs.add('-i "${filePaths[j]}"');

      String currentInput = inputLabel;
      String finalOutputLabel = '[a${j}_final]';

      // 1. Apply Fade-Out (to all but the last file)
      if (j < filePaths.length - 1) {
        final double fadeOutStartTime = fileDurations[j] - fadeDurationSec;
        final String fadeOutLabel = '[a${j}_fout]';

        // Filter: Raw Input -> afade out -> unique fade-out label
        filters.add('$inputLabel afade=t=out:st=${fadeOutStartTime.toStringAsFixed(3)}:d=${fadeDurationSec.toStringAsFixed(3)}:curve=qua$fadeOutLabel');

        currentInput = fadeOutLabel; // The fade-out output becomes the base for the next step (fade-in or final output)
      }

      // 2. Apply Fade-In (to all but the first file)
      if (j > 0) {
        // Filter: Input (raw or fade-out label) -> afade in -> final output label
        filters.add('$currentInput afade=t=in:st=0:d=${fadeDurationSec.toStringAsFixed(3)}:curve=qua$finalOutputLabel');
      } else {
        // For the first file (j=0), the final output is just the fade-out result
        // or the original input if there's no fade.
        finalOutputLabel = currentInput; // Use the [a0_fout] label as the final output label
      }

      concatInputs.add(finalOutputLabel);
    }

    // C. Concatenate all modified audio streams using the concat filter
    filters.add('${concatInputs.join()} concat=n=${filePaths.length}:v=0:a=1[aout]');

    // D. Assemble and Execute the command
    String filterComplex = filters.join(';');
    String finalLabel = '[aout]';

    // Use libmp3lame for MP3 output
    String command = '${inputs.join(' ')} '
        '-filter_complex "$filterComplex" '
        '-map "$finalLabel" -c:a libmp3lame -b:a 192k -y "$finalOutputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      onSuccess(finalOutputPath);
    } else {
      if (kDebugMode) {
        print("FFmpeg Single-Command Fade Failed. Command: $command");
        print("Error: ${await session.getOutput()}");
      }
      onFailed();
      return null;
    }

    // Since this is a single, large command, we report progress based on its execution time.
    // Progress tracking for a single, long command is simpler than chunking.
    // The executeAsync structure is better for the UI progress bar.
    // We will keep the simplest execution:
    // NOTE: If you need async progress tracking, you would use executeAsync here instead of execute.
    // For simplicity and guaranteed execution, I used the blocking execute above.

    return finalOutputPath;
  }

  static Future<String?> concatAudiosWithFadeChunked(
      List<String> filePaths,
      int fadeDurationMs, // Represents the duration of the fade-out and fade-in
      Function(String outputPath) onSuccess,
      Function() onFailed,
      Function(double progress) onProgress,
      ) async {
    const int chunkSize = 8;
    final double fadeDurationSec = fadeDurationMs / 1000.0;

    // --- Step 1: Setup ---
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate');
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);
    }
    String finalOutputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.mp3';

    // --- Step 2: Process chunks with Fade-Out/Fade-In ---
    List<String> chunkOutputs = [];

    for (int i = 0; i < filePaths.length; i += chunkSize) {
      List<String> chunk = filePaths.sublist(
        i,
        (i + chunkSize > filePaths.length) ? filePaths.length : i + chunkSize,
      );

      String chunkOutputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}_chunk.mp3';
      chunkOutputs.add(chunkOutputPath);

      if (chunk.length == 1) {
        // Handle single file copy
        await File(chunk[0]).copy(chunkOutputPath);
      } else {
        // A. Get durations for all files in the chunk
        List<double> fileDurations = [];
        for (String path in chunk) {
          fileDurations.add(await getDurationSeconds(path));
        }

        // B. Build the FFmpeg command
        List<String> inputs = [];
        List<String> filters = [];
        List<String> concatInputs = [];

        for (int j = 0; j < chunk.length; j++) {
          final String inputLabel = '[${j}:a]';
          final String currentOutputLabel = '[a${j}]';
          inputs.add('-i "${chunk[j]}"');

          String filterChain = inputLabel;

          // 1. Apply Fade-Out to all but the last file
          if (j < chunk.length - 1) {
            // Calculate fade-out start time
            final double fadeOutStartTime = fileDurations[j] - fadeDurationSec;
            // afade: t=out (fade out), st=start time, d=fade duration, curve=qua (quadratic is smooth)
            filterChain += 'afade=t=out:st=${fadeOutStartTime.toStringAsFixed(3)}:d=${fadeDurationSec.toStringAsFixed(3)}:curve=qua';
          }

          // 2. Apply Fade-In to all but the first file
          if (j > 0) {
            // If fade-out was applied, append to the chain. Otherwise, start a new chain.
            if (j < chunk.length - 1) {
              filterChain += ','; // Separate filters on the same chain
            } else {
              // If it's the last file, it only needs a fade-in.
              filterChain = inputLabel; // Reset to input label
            }

            // afade: t=in (fade in), st=0 (start time 0), d=fade duration, curve=qua
            filterChain += 'afade=t=in:st=0:d=${fadeDurationSec.toStringAsFixed(3)}:curve=qua';
          }

          // Apply the final output label and add to the filters list
          filterChain += currentOutputLabel;
          filters.add(filterChain);

          // Add the final labeled stream to the concat list
          concatInputs.add(currentOutputLabel);
        }

        // C. Concatenate all modified audio streams using the concat filter
        filters.add('${concatInputs.join()} concat=n=${chunk.length}:v=0:a=1[aout]');

        String filterComplex = filters.join(';');
        String finalLabel = '[aout]';
        String command = '${inputs.join(' ')} '
            '-filter_complex "$filterComplex" '
            '-map "$finalLabel" -c:a libmp3lame -b:a 192k -y "$chunkOutputPath"';

        // EXECUTE AND WAIT FOR COMPLETION
        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        Duration duration = await AudioUtils.getAudioFileLength(chunkOutputPath)?? Duration.zero;
        print("length: ${duration!.inMilliseconds}");

        // CRITICAL CHECK: Ensure the FFmpeg command succeeded
        if (!ReturnCode.isSuccess(returnCode)) {
          print("FFmpeg Chunk (Fade) Failed. Command: $command");
          print("Error: ${await session.getOutput()}");
          onFailed();
          return null;
        }

        if (!await File(chunkOutputPath).exists()) {
          onFailed();
          return null;
        }
      }
    }

    // --- Step 3: Create list file for final concat ---
    String listFilePath = '${appDirectory.path}/intermediate/${const Uuid().v1()}_list.txt';
    File listFile = File(listFilePath);
    String fileListContent = chunkOutputs
        .map((path) => "file '$path'")
        .join('\n');
    await listFile.writeAsString(fileListContent);

    // --- Step 4: Final concat of chunks (using -c copy) ---
    String concatCmd =
        '-f concat -safe 0 -i "$listFilePath" -c copy -y "$finalOutputPath"';

    await FFmpegKit.executeAsync(
      concatCmd,
          (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSuccess(finalOutputPath);
        } else {
          onFailed();
        }
      },
          (log) => print(log.getMessage()),
          (stats) => onProgress(0.7 + stats.getTime().toDouble() * 0.003),
    );

    return finalOutputPath;
  }

  static Future<String?> concatAudiosWithOverlapChunked(
      List<String> filePaths,
      int overlapDurationMs,
      Function(String outputPath) onSuccess,
      Function() onFailed,
      Function(double progress) onProgress,
      ) async {
    const int chunkSize = 8;
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    String finalOutputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.m4a';

    // Step 2: Process chunks with acrossfade
    List<String> chunkOutputs = [];

    for (int i = 0; i < filePaths.length; i += chunkSize) {
      List<String> chunk = filePaths.sublist(
        i,
        (i + chunkSize > filePaths.length) ? filePaths.length : i + chunkSize,
      );

      String chunkOutputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}_chunk.m4a';
      chunkOutputs.add(chunkOutputPath);

      if (chunk.length == 1) {
        await File(chunk[0]).copy(chunkOutputPath);
      } else {
        List<String> inputs = [];
        List<String> filters = [];

        for (int j = 0; j < chunk.length; j++) {
          inputs.add('-i "${chunk[j]}"');
        }

        for (int j = 0; j < chunk.length - 1; j++) {
          String inA = j == 0 ? '[0:a]' : '[a$j]';
          String inB = '[${j + 1}:a]';
          String out = '[a${j + 1}]';
          filters.add('$inA${inB}acrossfade=d=${overlapDurationMs / 1000}:c1=tri:c2=tri$out');
        }

        String filterComplex = filters.join(';');
        String lastLabel = '[a${chunk.length - 1}]';
        String command = '${inputs.join(' ')} '
            '-filter_complex "$filterComplex" '
            '-map "$lastLabel" -y "$chunkOutputPath"';

        await FFmpegKit.execute(command);
      }
    }

    // Step 3: Create list file for final concat
    String listFilePath = '${appDirectory.path}/intermediate/${const Uuid().v1()}_list.txt';
    File listFile = File(listFilePath);
    String fileListContent = chunkOutputs
        .map((path) => "file '$path'")
        .join('\n');
    await listFile.writeAsString(fileListContent);

    // Step 4: Final concat of chunks
    String concatCmd =
        '-f concat -safe 0 -i "$listFilePath" -c copy -y "$finalOutputPath"';

    await FFmpegKit.executeAsync(
      concatCmd,
          (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSuccess(finalOutputPath);
        } else {
          onFailed();
        }
      },
      (log) => print(log.getMessage()),
      (stats) => onProgress(0.7 + stats.getTime().toDouble() * 0.003),
    );

    return finalOutputPath;
  }


  static Future<String?> concatRemoteAudios(List<String> fileUrls, Function onSuccess, Function onFailed, Function onProgress) async {
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    String outputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.m4a';
    String listFilePath = '${appDirectory.path}/intermediate/concat_list.txt';

    // Download all files concurrently
    List<Future<String?>> downloadTasks = fileUrls.map((url) async {
      try {
        String localFilePath = '${appDirectory.path}/${const Uuid().v1()}.m4a';
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          File file = File(localFilePath);
          await file.writeAsBytes(response.bodyBytes);
          return localFilePath;
        } else {
          print("Failed to download: $url");
          return null;
        }
      } catch (e) {
        print("Error downloading $url: $e");
        return null;
      }
    }).toList();

    // Wait for all downloads to complete
    List<String> localFilePaths = (await Future.wait(downloadTasks))
        .whereType<String>() // Filter out failed downloads
        .toList();

    if (localFilePaths.isEmpty) {
      print("No files downloaded successfully.");
      return null;
    }

    // Create concat list file
    File listFile = File(listFilePath);
    String fileListContent = localFilePaths.map((path) => "file '$path'").join('\n');
    await listFile.writeAsString(fileListContent);

    // FFmpeg command to concatenate audio files
    await FFmpegKit.executeAsync(
      '-f concat -safe 0 -i $listFilePath -c copy $outputPath',
          (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSuccess(outputPath);
        } else {
          onFailed();
        }
      },
      (Log log) => print(log.getMessage()),
      (Statistics statistics) => print("Processing: ${statistics.getTime()}"),
    );

    return outputPath;
  }

  static Future<String?> clearNoise(String filePath, String noiseLoudness, Function onSuccess, Function onFailed, Function onProgress) async {
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    String outputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.wav';

    // FFmpeg command to concatenate audio files
    await FFmpegKit.executeAsync(
      '-i $filePath -af "afftdn=nf=$noiseLoudness,agate=threshold=${noiseLoudness}dB, loudnorm=I=-19:TP=-2:LRA=11" -ac 1 $outputPath',
          (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSuccess(outputPath);
        } else {
          onFailed();
        }
      },
      (Log log) => print(log.getMessage()),
      (Statistics statistics) => onProgress(statistics.getTime()),
    );

    return outputPath;
  }

  static Future<String?> clearNoiseSync(String filePath, String noiseLoudness) async {
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    String outputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.wav';

    // FFmpeg command to concatenate audio files
    FFmpegSession session = await FFmpegKit.execute('-i $filePath -af "afftdn=nf=$noiseLoudness,agate=threshold=${noiseLoudness}dB, loudnorm=I=-19:TP=-2:LRA=11" $outputPath');
    ReturnCode? returnCode = await session.getReturnCode();
    if(!ReturnCode.isSuccess(returnCode)) {
      return null;
    }

    return outputPath;
  }

  static Future<String?> convertMp3ToOggOpus(String filePath) async {
    final Directory appDirectory = await getTemporaryDirectory();
    final Directory intermediateFolder =
    Directory('${appDirectory.path}/intermediate');

    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);
    }

    final String outputPath =
        '${intermediateFolder.path}/${const Uuid().v1()}.ogg';

    final String command =
        '-i "$filePath" -c:a libopus -page_duration 20000 -vn "$outputPath"';

    final FFmpegSession session = await FFmpegKit.execute(command);
    final ReturnCode? returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      return null;
    }

    return outputPath;
  }

  static Future<String?> trimWavAudioSync({
    required String filePath,
    required Duration start,
    required Duration end,
  }) async {
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    String outputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.wav';

    // FFmpeg command to trim audio
    final command = '-i $filePath -ss ${start.inSeconds} -to ${end.inSeconds} -c copy $outputPath';

    FFmpegSession session = await FFmpegKit.execute(command);
    ReturnCode? returnCode = await session.getReturnCode();
    if(!ReturnCode.isSuccess(returnCode)) {
      return null;
    }

    return outputPath;
  }

  static Future<String?> encodeToM4a(String wavFilePath) async {
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    String m4aOutputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.m4a';

    final command = '-i $wavFilePath -ar 44100 -ac 1 -c:a aac -b:a 192k  $m4aOutputPath';

    FFmpegSession session = await FFmpegKit.execute(command);
    ReturnCode? returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      return null;
    }

    return m4aOutputPath;
  }

  static String? extensionFromMime(String? mime) {
    if (mime == null) return null;
    final lower = mime.toLowerCase();
    if (lower.contains('audio/mpeg')) return '.mp3';
    if (lower.contains('audio/mp4') || lower.contains('audio/x-m4a') || lower.contains('audio/aac')) return '.m4a';
    if (lower.contains('audio/wav') || lower.contains('audio/x-wav')) return '.wav';
    return null;
  }

  static Future<String?> decodeM4aToWav(String m4aFilePath) async {
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    String wavOutputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.wav';

    final command = '-i $m4aFilePath -ar 44100 -ac 1 -c:a pcm_s16le $wavOutputPath';

    FFmpegSession session = await FFmpegKit.execute(command);
    ReturnCode? returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      return null;
    }

    return wavOutputPath;
  }

  static Future<String?> normalizeAudio(String filePath, String outputType, Function onSuccess, Function onFailed, Function onProgress, bool changeVoice, {int? noiseLoudness}) async {
    Directory appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate'); // Specify folder name
    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);  // Create the folder
    }
    String outputPath = '${appDirectory.path}/intermediate/${const Uuid().v1()}.$outputType';
    String noiseReduction = noiseLoudness != null ? 'afftdn=nf=$noiseLoudness,' : '';
    String disguise = changeVoice
        ? 'asetrate=48000*1.189207,atempo=${1/1.189207},aresample=48000,'
        : '';

    String cmd = '-threads ${Platform.numberOfProcessors} -i $filePath -af "${disguise}${noiseReduction}agate=threshold=${noiseLoudness?? -37}dB, loudnorm=I=-19:TP=-2:LRA=11" -ac 1 $outputPath';
    // String cmd = '-threads ${Platform.numberOfProcessors} -i $filePath -af "${disguise}" -ac 1 $outputPath';
    // FFmpeg command to normalize audio
    await FFmpegKit.executeAsync(
      cmd,
      (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSuccess(outputPath);
        } else {
          onFailed();
        }
      },
      (Log log) => print(log.getMessage()),
      (Statistics statistics) => onProgress(statistics.getTime()),
    );

    return outputPath;
  }

  static Future<String?> fixMusicToTargetMeanVolume(
      String inputFilePath, {
        double targetMeanVolumeDb = -20.0,
      }) async {
    final appDirectory = await getTemporaryDirectory();
    final intermediateFolder = Directory('${appDirectory.path}/intermediate');

    if (!(await intermediateFolder.exists())) {
      await intermediateFolder.create(recursive: true);
    }

    final outputPath =
        '${appDirectory.path}/intermediate/${const Uuid().v1()}.mp3';

    final volumeInfo = await getAudioVolumeInfo(inputFilePath);
    if (volumeInfo == null || volumeInfo.meanVolumeDb == null) {
      return null;
    }

    final currentMean = volumeInfo.meanVolumeDb!;
    final gainDb = targetMeanVolumeDb - currentMean;

    final command =
        '-i "$inputFilePath" '
        '-af "volume=${gainDb}dB" '
        '-c:a libmp3lame -b:a 192k '
        '"$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      return null;
    }

    return outputPath;
  }

  static Future<AudioVolumeInfo?> getAudioVolumeInfo(String filePath) async {
    final session = await FFmpegKit.execute(
      '-i "$filePath" -af volumedetect -f null -',
    );

    final logs = await session.getAllLogsAsString();

    final meanMatch =
    RegExp(r'mean_volume:\s*(-?\d+(?:\.\d+)?) dB').firstMatch(logs ?? "");
    final maxMatch =
    RegExp(r'max_volume:\s*(-?\d+(?:\.\d+)?) dB').firstMatch(logs ?? "");

    final meanVolumeDb =
    meanMatch != null ? double.tryParse(meanMatch.group(1)!) : null;
    final maxVolumeDb =
    maxMatch != null ? double.tryParse(maxMatch.group(1)!) : null;

    if (meanVolumeDb == null) {
      return null;
    }

    return AudioVolumeInfo(
      meanVolumeDb: meanVolumeDb,
      maxVolumeDb: maxVolumeDb,
    );
  }
}

class AudioVolumeInfo {
  final double? meanVolumeDb;
  final double? maxVolumeDb;

  AudioVolumeInfo({
    required this.meanVolumeDb,
    required this.maxVolumeDb,
  });
}