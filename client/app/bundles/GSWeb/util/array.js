

export default function remove(array, func) {
  const filteredArray = [];
  array.forEach((element) => {
    !func(element) && filteredArray.push(element)
  })
  return filteredArray;
}