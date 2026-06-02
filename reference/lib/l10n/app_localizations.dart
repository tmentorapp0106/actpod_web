import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @actpodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your story, interact with audience'**
  String get actpodSubtitle;

  /// No description provided for @searchStoryName.
  ///
  /// In en, this message translates to:
  /// **'Search Story Name'**
  String get searchStoryName;

  /// No description provided for @boardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Boards'**
  String get boardsTitle;

  /// No description provided for @boardsApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get boardsApply;

  /// No description provided for @boardName.
  ///
  /// In en, this message translates to:
  /// **'Board Name '**
  String get boardName;

  /// No description provided for @boardDesc.
  ///
  /// In en, this message translates to:
  /// **'Board Desc '**
  String get boardDesc;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @boardApplication.
  ///
  /// In en, this message translates to:
  /// **'Board Application'**
  String get boardApplication;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @soundEffect.
  ///
  /// In en, this message translates to:
  /// **'Sound Effect'**
  String get soundEffect;

  /// No description provided for @doneRecording.
  ///
  /// In en, this message translates to:
  /// **'Done Recording?'**
  String get doneRecording;

  /// No description provided for @doneRecordingDescription.
  ///
  /// In en, this message translates to:
  /// **'Once you leave this page you will not be able to continue recording later.'**
  String get doneRecordingDescription;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @audition.
  ///
  /// In en, this message translates to:
  /// **'Audition'**
  String get audition;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @selectBoard.
  ///
  /// In en, this message translates to:
  /// **'Select Board'**
  String get selectBoard;

  /// No description provided for @pleaseSelectBoard.
  ///
  /// In en, this message translates to:
  /// **'Please Select Board'**
  String get pleaseSelectBoard;

  /// No description provided for @pleaseSelectBackgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'Please Select Background Music'**
  String get pleaseSelectBackgroundMusic;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @backgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get backgroundMusic;

  /// No description provided for @voiceVolume.
  ///
  /// In en, this message translates to:
  /// **'Voice Volume'**
  String get voiceVolume;

  /// No description provided for @backgroundVolume.
  ///
  /// In en, this message translates to:
  /// **'Background Volume'**
  String get backgroundVolume;

  /// No description provided for @applyTo.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyTo;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'Sec'**
  String get sec;

  /// No description provided for @uploadStory.
  ///
  /// In en, this message translates to:
  /// **'Upload Story'**
  String get uploadStory;

  /// No description provided for @giveYourStoryAName.
  ///
  /// In en, this message translates to:
  /// **'Give your story a name'**
  String get giveYourStoryAName;

  /// No description provided for @giveYourStoryADescription.
  ///
  /// In en, this message translates to:
  /// **'Give your story a description'**
  String get giveYourStoryADescription;

  /// No description provided for @typeHere.
  ///
  /// In en, this message translates to:
  /// **'Type Here...'**
  String get typeHere;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @pleaseCompleteYourInput.
  ///
  /// In en, this message translates to:
  /// **'Please complete your input'**
  String get pleaseCompleteYourInput;

  /// No description provided for @selectUpTo3Categories.
  ///
  /// In en, this message translates to:
  /// **'Select up to 3 Categories'**
  String get selectUpTo3Categories;

  /// No description provided for @enableVoiceMessages.
  ///
  /// In en, this message translates to:
  /// **'Enable Voice Messages?'**
  String get enableVoiceMessages;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @voiceMessageExplanation.
  ///
  /// In en, this message translates to:
  /// **'Anyone can leave a voice message which you can add to your story and respond to.'**
  String get voiceMessageExplanation;

  /// No description provided for @voiceMessageExplanationTurnOff.
  ///
  /// In en, this message translates to:
  /// **'No one can leave voice messages on this story.'**
  String get voiceMessageExplanationTurnOff;

  /// No description provided for @uploadPreview.
  ///
  /// In en, this message translates to:
  /// **'Upload Preview'**
  String get uploadPreview;

  /// No description provided for @uploadPicture.
  ///
  /// In en, this message translates to:
  /// **'Upload Picture'**
  String get uploadPicture;

  /// No description provided for @continueRecording.
  ///
  /// In en, this message translates to:
  /// **'Continue Recording'**
  String get continueRecording;

  /// No description provided for @openVoiceList.
  ///
  /// In en, this message translates to:
  /// **'Open Voice List'**
  String get openVoiceList;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @addedToList.
  ///
  /// In en, this message translates to:
  /// **'Added to list'**
  String get addedToList;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @nextStory.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextStory;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addComment;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get replies;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @addReply.
  ///
  /// In en, this message translates to:
  /// **'Add Reply'**
  String get addReply;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @blockStory.
  ///
  /// In en, this message translates to:
  /// **'Block Story'**
  String get blockStory;

  /// No description provided for @removeStory.
  ///
  /// In en, this message translates to:
  /// **'Remove Story'**
  String get removeStory;

  /// No description provided for @stopReceivingVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Stop Receiving Voice Message'**
  String get stopReceivingVoiceMessage;

  /// No description provided for @startReceivingVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Start Receiving Voice Message'**
  String get startReceivingVoiceMessage;

  /// No description provided for @storyDescription.
  ///
  /// In en, this message translates to:
  /// **'Story Description'**
  String get storyDescription;

  /// No description provided for @endUserLicenseAgreement.
  ///
  /// In en, this message translates to:
  /// **'End-User License Agreement'**
  String get endUserLicenseAgreement;

  /// No description provided for @endUserRules.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms\n  Using ActPod means you agree to this EULA. If not, do not use the app.\n  2. User Conduct\n  No posting of illegal, offensive, or abusive content.\n  No harassment, bullying, or threats.\n  3. Prohibited Uses\n  The app must not be used unlawfully or to harm the service.\n  4. Enforcement\n  We may remove harmful content and take action against offenders, including account termination.\n  5. Reporting Issues\n  Report problems via report system provided in the ActPod.\n  6. Changes to EULA\n  We may update this EULA. Continued use means acceptance of new terms.\n  7. Contact\n  Questions? Contact us by email easonproject106@gmail.com.'**
  String get endUserRules;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @podCoins.
  ///
  /// In en, this message translates to:
  /// **'Pod Coins'**
  String get podCoins;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @buyPodCoins.
  ///
  /// In en, this message translates to:
  /// **'Buy Pod Coins'**
  String get buyPodCoins;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @remain.
  ///
  /// In en, this message translates to:
  /// **'Remain'**
  String get remain;

  /// No description provided for @longPressToRecord.
  ///
  /// In en, this message translates to:
  /// **'Long press to Record'**
  String get longPressToRecord;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @withdrawFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Feature Coming Soon.'**
  String get withdrawFeatureComingSoon;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @syncRSS.
  ///
  /// In en, this message translates to:
  /// **'Sync RSS'**
  String get syncRSS;

  /// No description provided for @changeRegion.
  ///
  /// In en, this message translates to:
  /// **'Change Region'**
  String get changeRegion;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logOut;

  /// No description provided for @removeAccount.
  ///
  /// In en, this message translates to:
  /// **'Remove Account'**
  String get removeAccount;

  /// No description provided for @syncRSSFeed.
  ///
  /// In en, this message translates to:
  /// **'Sync RSS Feed'**
  String get syncRSSFeed;

  /// No description provided for @pastRssFeedHere.
  ///
  /// In en, this message translates to:
  /// **'Paste RSS Feed here'**
  String get pastRssFeedHere;

  /// No description provided for @rSSFeedNotification.
  ///
  /// In en, this message translates to:
  /// **'Notice:\n\nKindly ensure that you have ownership rights to this RSS Feed. Otherwise, you will be held responsible for copyright infringement.'**
  String get rSSFeedNotification;

  /// No description provided for @selectEpisodesToUpload.
  ///
  /// In en, this message translates to:
  /// **'Please Select Episodes To Upload'**
  String get selectEpisodesToUpload;

  /// No description provided for @editStories.
  ///
  /// In en, this message translates to:
  /// **'Edit Stories'**
  String get editStories;

  /// No description provided for @storyName.
  ///
  /// In en, this message translates to:
  /// **'Story Name'**
  String get storyName;

  /// No description provided for @selectCategories.
  ///
  /// In en, this message translates to:
  /// **'Select Categories'**
  String get selectCategories;

  /// No description provided for @uploadProcessing.
  ///
  /// In en, this message translates to:
  /// **'Upload Processing'**
  String get uploadProcessing;

  /// No description provided for @rssFeedUploadingDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Sync task is processing, it\'ll take around 10 min. Please check personal story list after 10 min.'**
  String get rssFeedUploadingDialogContent;

  /// No description provided for @pleaseInputRssFeed.
  ///
  /// In en, this message translates to:
  /// **'Please input RSS feed'**
  String get pleaseInputRssFeed;

  /// No description provided for @pleaseSelectEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Please select episodes'**
  String get pleaseSelectEpisodes;

  /// No description provided for @pleaseSelectCategories.
  ///
  /// In en, this message translates to:
  /// **'Please select categories'**
  String get pleaseSelectCategories;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
