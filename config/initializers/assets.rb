Rails.application.config.assets.precompile += [
    'user_email_preferences.css',
    'user_signup.css',
    'user_help.js',
    'admin_postload.js',
    'widget_map.js',
    'district-boundaries.css',
    'search.css',
    'my-saved-school-list.css',
    'account.css',
    'widget.css',
    'widget-form.css',
    'wordpress-modals.js',
    'wordpress-modals.css',
    'header.js',
    'header.css',
    'post_load.css',
    'community_post_load.css',
    'home_page.css',
    'deprecated_application.css',
    'deprecated_application.js',
    'deprecated_post_load.js',
    'deprecated_post_load_adapter.js',
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
    'js.cookie.js',
    'galleria-1.3.1.js',
    'galleria.classic.js',
    'main.css', #for style-guide
    'main.js', #for style-guide
    'picturefill.min.js', #for style-guide
    'highcharts.js',
    'api_documentation.css',
    'admin_tools.css',
    'add_remove_schools.css',
    'city.css',
    'district.css',
    'compare.css',
    'college-success-award.css',
    'state.css'
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
