public with sharing class ListUtils {
	
	public static List<String> deDuplicate(List<String> stringList) {
		Set<String> stringSet = new Set<String>();
		stringSet.addAll(stringList);
		stringList.clear();
		stringList.addAll(stringSet);
		return stringList;
	}

	public static List<Id> deDuplicate(List<Id> idList) {
		Set<Id> idSet = new Set<Id>();
		idSet.addAll(idList);
		idList.clear();
		idList.addAll(idSet);
		return idList;
	}

	public static Boolean isNullOrEmpty(List<Object> theList) {
		if (theList == null || theList.isEmpty()) {
			return true;
		}
		return false;
	}

	public static Boolean isNotNullOrEmpty(List<Object> theList) {
		if (theList == null || theList.isEmpty()) {
			return false;
		}
		return true;
	}

	public static Map<String, Integer> getStringToQuantitiesMap(List<String> stringList) {
		if (isNullOrEmpty(stringList)) {
			return null;
		}
		Map<String, Integer> result = new Map<String, Integer>();
		Integer quantity;
		for (String item : stringList) {
			if (result.get(item) == null) {
				result.put(item, 1);
			}
			else {
				quantity = result.get(item);
				result.put(item, quantity + 1);
			}
		}
		return result;
	}
}