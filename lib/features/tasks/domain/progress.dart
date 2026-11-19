/// Done out of total: today's ring (S07), a project's bar (S26, S27).
typedef Progress = ({int done, int total});

extension ProgressValues on Progress {
  /// 0 when there's nothing to do, so an empty ring stays empty (S08).
  double get fraction => total == 0 ? 0 : done / total;

  int get percent => (fraction * 100).round();
}
