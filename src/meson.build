module_name='markdown-actions'
sources = files('plugin-main.vala')

shared_module(
    module_name,
    sources,
    dependencies: dependencies,
    install: true,
    install_dir: join_paths(pluginsdir, module_name)
)

custom_target(module_name + '.plugin_merge',
    input: module_name + '.plugin',
    output: module_name + '.plugin',
    command : [msgfmt,
               '--desktop',
               '--keyword=Description',
               '--keyword=Name',
               '-d' + join_paths(meson.source_root (), 'po', 'plugins'),
               '--template=@INPUT@',
               '-o@OUTPUT@',
               ],
    install : true,
    install_dir: join_paths(pluginsdir, module_name),
)

