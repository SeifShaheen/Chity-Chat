class Helpers {
  static findById(list, String id) {
    findBy(obj) => obj == id;
    var result = list.where(findBy);
    return result.length > 0 ? result.first : null;
  }
}
