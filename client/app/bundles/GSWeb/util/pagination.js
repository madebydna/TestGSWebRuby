export default function pages(currentPage, totalPages) {
  const pagesRemaining = Math.min(totalPages, 7);

  let prev = null;
  if (currentPage > 1) {
    prev = currentPage - 1;
  }
  let next = null;
  if (currentPage < totalPages) {
    next = currentPage + 1;
  }

  const middle = [];
  if (totalPages > 0) {
    const start = Math.max(
      1,
      Math.min(totalPages - 1, Math.max(1, currentPage))
    );
    middle.push(start);
    let middleLength;
    do {
      middleLength = middle.length;
      const min = middle[0];
      if (min > 1) {
        middle.unshift(min - 1);
      }
      if (middle.length >= pagesRemaining) {
        break;
      }
      const max = middle[middle.length - 1];
      if (max < totalPages) {
        middle.push(max + 1);
      }
    } while (middle.length < pagesRemaining && middleLength !== middle.length);
  }

  const pageArray = middle;

  return { prev, next, range: pageArray };
}
