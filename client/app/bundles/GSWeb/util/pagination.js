export default function pages(currentPage, totalPages) {
  let pagesRemaining = Math.min(totalPages, 5);

  let prev = null;
  if (currentPage > 1) {
    prev = currentPage - 1;
  }
  let next = null;
  if (currentPage < totalPages) {
    next = currentPage + 1;
  }

  const first = [];
  if (totalPages > 1) {
    first.push(1);
    pagesRemaining -= 1;
  }

  const last = [];
  if (totalPages > 1) {
    last.push(totalPages);
    pagesRemaining -= 1;
  }

  const middle = [];
  if (totalPages > 2) {
    const start = Math.max(
      1,
      Math.min(totalPages - 1, Math.max(2, currentPage))
    );
    middle.push(start);
    let middleLength;
    do {
      middleLength = middle.length;
      const min = middle[0];
      if (min > 2) {
        middle.unshift(min - 1);
      }
      if (middle.length >= pagesRemaining) {
        break;
      }
      const max = middle[middle.length - 1];
      if (max < totalPages - 1) {
        middle.push(max + 1);
      }
    } while (middle.length < pagesRemaining && middleLength !== middle.length);
  }

  const pageArray = first.concat(middle).concat(last);

  return { prev, next, range: pageArray };
}
