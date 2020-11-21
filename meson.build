project('Markdown Actions Plugin', 'vala', 'c')

msgfmt = find_program('msgfmt')
codecore_dep = dependency('codecore')
dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('libsoup-2.4'),
    dependency('libpeas-1.0'),
    dependency('libhandy-1', version: '>=0.90.0'),
    codecore_dep
]

subdir('src')