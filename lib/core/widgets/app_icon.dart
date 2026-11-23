import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The app's line icons (DESIGN §8): Lucide (ISC licence, lucide-static
/// 1.72.0) on a 24 grid with round caps and joins, bundled in
/// `assets/icons/`. Data stores project icon keys, never these.
enum AppIcon {
  add('plus'),
  alert('circle-alert'),
  arrowUp('arrow-up'),
  arrowUpRight('arrow-up-right'),
  bag('shopping-bag'),
  bell('bell'),
  book('book-open'),
  box('box'),
  briefcase('briefcase'),
  calendar('calendar'),
  chart('chart-column-big'),
  check('check'),
  chevronLeft('chevron-left'),
  chevronRight('chevron-right'),
  clock('clock'),
  close('x'),

  /// ••• (S27).
  ellipsis('ellipsis'),
  filter('list-filter'),
  code('code'),
  coffee('coffee'),
  flag('flag'),
  flagFilled('flag-filled'),
  flame('flame'),
  folder('folder'),
  folderPlus('folder-plus'),
  gift('gift'),
  globe('globe'),
  heart('heart'),
  home('house'),
  inbox('inbox'),
  info('info'),
  link('link'),
  list('list'),
  minus('minus'),
  palette('palette'),

  /// Solid, as S30's play button.
  pause('pause'),
  plane('send'),

  /// Solid, as S30's play button.
  play('play'),
  repeat('repeat'),
  reset('rotate-ccw'),
  search('search'),
  searchNone('search-x'),
  skipForward('skip-forward'),
  sliders('sliders-horizontal'),
  subtask('corner-down-right'),
  success('circle-check'),
  tag('tag'),
  tasks('list-checks'),
  timer('timer'),
  trash('trash-2'),
  user('user'),
  warning('triangle-alert'),
  zap('zap');

  new(this.file);

  final String file;

  String get asset => 'assets/icons/$file.svg';
}

/// Stroke widths from DESIGN §8.
abstract final class AppIconStroke {
  static const double nav = 1.7;
  static const double button = 1.8;
  static const double tile = 1.9;
  static const double chevron = 2.2;
}

/// Draws an [AppIcon]. Size and colour default to the surrounding
/// `IconTheme`, as `Icon` does, so it works inside `IconButton`.
/// Decorative: screen readers skip it; label the button instead.
class AppIconView extends StatelessWidget {
  const new(
    this.icon, {
    this.size,
    this.color,
    this.stroke = AppIconStroke.button,
    super.key,
  });

  final AppIcon icon;
  final double? size;
  final Color? color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? 24;
    final tint = color ?? theme.color;
    // Like Icon: its own size, centred, even inside a tile that passes
    // tight constraints.
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SvgPicture(
        _StrokeLoader(icon.asset, stroke),
        width: side,
        height: side,
        colorFilter: tint == null
            ? null
            : ColorFilter.mode(tint, BlendMode.srcIn),
        excludeFromSemantics: true,
      ),
    );
  }
}

/// Loads an icon with its stroke width set: Lucide files use 2.
class _StrokeLoader extends SvgAssetLoader {
  const new(super.assetName, this.stroke);

  final double stroke;

  @override
  String provideSvg(ByteData? message) => super
      .provideSvg(message)
      .replaceFirst('stroke-width="2"', 'stroke-width="$stroke"');

  @override
  SvgCacheKey cacheKey(BuildContext? context) => SvgCacheKey(
    keyData: (assetName, stroke),
    colorMapper: colorMapper,
    theme: getTheme(context),
  );

  @override
  int get hashCode => Object.hash(super.hashCode, stroke);

  @override
  bool operator ==(Object other) =>
      other is _StrokeLoader && super == other && other.stroke == stroke;
}
