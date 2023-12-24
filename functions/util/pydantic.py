from pydantic import BaseModel

from enum import Enum


def generate_schema(model):
    schema = {'title': model.__name__, 'type': 'object',
              'properties': {}, 'required': []}
    for field_name, field in model.__fields__.items():
        field_schema = {'title': field_name, 'type': field.type_.__name__}
        if issubclass(field.type_, BaseModel):
            field_schema = generate_schema(field.type_)
        schema['properties'][field_name] = field_schema
        if field.required:
            schema['required'].append(field_name)
    return schema


def convert_enum_to_value(data):
    if isinstance(data, dict):
        return {k: convert_enum_to_value(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [convert_enum_to_value(element) for element in data]
    elif isinstance(data, Enum):
        return data.value
    else:
        return data


def convert_model_to_dict(data):
    from pydantic import BaseModel

    if isinstance(data, dict):
        return {k: convert_model_to_dict(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [convert_model_to_dict(element) for element in data]
    elif isinstance(data, BaseModel):
        return convert_model_to_dict(data.dict())
    else:
        return data
