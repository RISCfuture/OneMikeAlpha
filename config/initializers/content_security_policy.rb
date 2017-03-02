# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# Mapbox requires:
# - child-src blob:
# - img-src data: blob:
# - script-src 'unsafe-eval'
# - connect-src 'https://*.tiles.mapbox.com' 'https://api.mapbox.com' 'https://events.mapbox.com'
#
# Google Fonts requires:
# - font-src 'https://fonts.gstatic.com'
# - style-src 'https://fonts.googleapis.com'
#
# Vue.js in development requires:
# - connect-src 'ws://localhost:3035' 'http://localhost:3035'
# - script-src 'unsafe-eval'
#
# ActionCable in development requires:
# - connect-src 'ws://localhost:28080'

extra_connect_sources = Array.new
extra_script_sources = Array.new
extra_style_sources = Array.new
if Rails.env.development?
  extra_connect_sources << 'ws://localhost:3035' << 'http://localhost:3035' << 'ws://localhost:28080'
  extra_script_sources << :unsafe_eval
  extra_style_sources << :unsafe_inline
else
  Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
end

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src    :self, :data, 'https://fonts.gstatic.com'
  policy.img_src     :self, :data, :blob
  policy.object_src  :none
  policy.script_src  :self, *extra_script_sources
  policy.style_src   :self, 'https://fonts.googleapis.com', *extra_style_sources
  policy.child_src :blob
  policy.connect_src :self, 'https://*.tiles.mapbox.com',
                     'https://api.mapbox.com', 'https://events.mapbox.com',
                     *extra_connect_sources

  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# Set the nonce only to specific directives
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
