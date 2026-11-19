/// Colour keys a project can use (DESIGN §3.4). The database stores the key,
/// never a colour value. Inbox and built-in projects use [grey].
enum ProjectColorKey { orange, yellow, green, blue, purple, pink, red, grey }

/// Icon keys a project can use (DESIGN §8), stored by name.
enum ProjectIconKey {
  globe,
  chart,
  home,
  code,
  plane,
  briefcase,
  bag,
  book,
  box,
  gift,
  palette,
  heart,
}
