from StringIO import StringIO

class Markdown(StringIO):
    def __init__(self):
        StringIO.__init__(self)
    def yamlHeader(self, title, layout='default-public-bodies', categories='service', subcategory=''):
        header = '''---
layout: {layout}
title: {title}
category: {categories}
subcategory: {subcategory}
---\n'''.format(layout=layout, title=title, categories=categories, subcategory=subcategory)
        self.write(header)

    def linkLine(self, text, url):
        self.link(text, url)
        self.write('\n')
    def link(self, text, url):
        line = '''[{text}]({url})'''.format(text=text, url=url)
        self.write(line)
    def htmlLink(self, text, url):
        line = '''<a href="{url}">{text}</a>'''.format(text=text, url=url)
        self.write(line)
    def line(self):
        self.write('\n')
    def tableStart(self, htmlClass=''):
        self.write('<table class="{0}">'.format(htmlClass))
    def tableHeader(self, headers):
        self.write('<thead>')
        cells = '<tr>' + ''.join(['<th>{content}</th>'.format(content=header) for header in headers]) + '</tr>'
        self.write(cells)
        self.write('</thead>')
    def tableEnd(self):
        self.write('</table>')
    def formatAttributes(self, attributes):
        return ' '.join(['{0}="{1}"'.format(str(k), str(v)) for (k,v) in attributes.items()])
    def tableRowStart(self, attributes={}):
        attributes_html = self.formatAttributes(attributes)
        self.write('<tr {attributes}>'.format(attributes=attributes_html));
    def tableCellStart(self, attributes={}):
        attributes_html = self.formatAttributes(attributes)
        self.write('<td {attributes}>'.format(attributes=attributes_html));
    def tableCellEnd(self):
        self.write('</td>')
    def tableRowEnd(self):
        self.write('</tr>')
    def tagStart(self, name, attributes = {}):
        self.write('<{0} {1}>'.format(name, self.formatAttributes(attributes)))
    def tagEnd(self, name):
        self.write('</{0}>'.format(name))
    def tag(self, name, contents='', attributes={}):
        self.tagStart(name, attributes)
        self.write(contents)
        self.tagEnd(name)
