import six
from jinja2 import BaseLoader, Markup, TemplateNotFound, nodes
from xml.dom import minidom
from xml.etree.ElementTree import Element, SubElement, tostring

def format_xml(value):
    """Render a formatted multi-line XML string from a complex Python
    data structure. Supports tag attributes and nested dicts/lists.

    :param value: Complex data structure representing XML contents
    :returns: Formatted XML string rendered with newlines and indentation
    :rtype: str
    """
    def normalize_iter(value):
        if isinstance(value, (list, tuple)):
            if isinstance(value[0], str):
                xmlval = value
            else:
                xmlval = []
        elif isinstance(value, dict):
            xmlval = list(value.items())
        else:
            raise TemplateRuntimeError(
                'Value is not a dict or list. Cannot render as XML')
        return xmlval

    def recurse_tree(xmliter, element=None):
        sub = None
        for tag, attrs in xmliter:
            if isinstance(attrs, list):
                for attr in attrs:
                    recurse_tree(((tag, attr),), element)
            elif element is not None:
                sub = SubElement(element, tag)
            else:
                sub = Element(tag)
            if isinstance(attrs, (str, int, bool, float)):
                sub.text = six.text_type(attrs)
                continue
            if isinstance(attrs, dict):
                sub.attrib = {attr: six.text_type(val) for attr, val in attrs.items()
                              if not isinstance(val, (dict, list))}
            for tag, val in [item for item in normalize_iter(attrs) if
                             isinstance(item[1], (dict, list))]:
                recurse_tree(((tag, val),), sub)
        return sub

    return Markup(minidom.parseString(
        tostring(recurse_tree(normalize_iter(value)))
    ).toprettyxml(indent=" "))
