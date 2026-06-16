part of 'player_web_screen.dart';

class _WebHeader extends StatelessWidget {
  final PlayerController playerController;

  const _WebHeader({required this.playerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Image.asset(
            "assets/images/actpod_logo_web.png",
            height: 30,
            fit: BoxFit.fitHeight,
          ),
          const Spacer(),
          _WebAccountButton(playerController: playerController),
        ],
      ),
    );
  }
}
