Rails.application.config.assets.precompile += [
    'widget_map.js',
    'district-boundaries-bundle.js',
    'district-boundaries.css',
    'widget.css',
    'widget-form.css',
    'wordpress-modals.js',
    'wordpress-modals.css',
    'header.js',
    'header.css',
    'post_load.js',
    'shared_post_load.js',
    'widget-bundle.js',
    'interstitial-bundle.js',
    'school-profiles-bundle.js',
    'post_load.css',
    'deprecated_application.css',
    'deprecated_application.js',
    'deprecated_post_load.js',
    'deprecated_post_load.css',
    'deprecated_print.css',
    'footer.css',
    'print.css',
    'cm_athena_gs_v2.js',
    # 'dropzone.min.js',
    'dropzone.css',
    'bootstrap-datepicker.min.js',
    'bootstrap-datepicker3.css',
    'jquery.timepicker.css',
    'jquery.timepicker.min.js',
    'galleria-1.3.1.js',
    'galleria.classic.js',
    'main.css', #for style-guide
    'main.js', #for style-guide
    'picturefill.min.js', #for style-guide
    'highcharts.js',
    'just_jquery.js'
]
# Add client/assets/ folders to asset pipeline's search path.
# If you do not want to move existing images and fonts from your Rails app
# you could also consider creating symlinks there that point to the original
# rails directories. In that case, you would not add these paths here.
# If you have a different server bundle file than your client bundle, you'll
# need to add it here, like this:
# Rails.application.config.assets.precompile += %w( server-bundle.js )

# Add folder with webpack generated assets to assets.paths
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "webpack")
