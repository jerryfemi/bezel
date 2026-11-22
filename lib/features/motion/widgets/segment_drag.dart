/// Where a dragged move would land.
///
/// Segments are numbered by their end keyframe (1..n−1); [mids] holds the x
/// centre of each. The answer is one more than the number of *other*
/// segments left of the pointer, which is the index `reorderSegments` expects.
int dropIndexFor(double pointerX, int dragged, List<double> mids) {
  var left = 0;
  for (var i = 0; i < mids.length; i++) {
    if (i + 1 != dragged && pointerX > mids[i]) left++;
  }
  return left + 1;
}
