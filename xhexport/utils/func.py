def combine_same_origin_items(source):
    result = []
    id_map = {}
    for item in source:
        if item['id'] in id_map:
            if 'user_extended' not in result[id_map[item['id']]]:
                result[id_map[item['id']]]['user_extended'] = []
            result[id_map[item['id']]]['user_extended'].append(item['user_id'])
        else:
            result.append(item)
            id_map[item['id']] = len(result) - 1
    return result
