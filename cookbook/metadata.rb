name             'aspnet_skeleton'
maintainer       'Allan Espinosa'
maintainer_email 'allan.espinosa@outlook.com'
license          'Apache v2'
description      'Deploys an ASP.NET app'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
depends          'iis', '~> 2.1.2'
depends          'artifact', '~> 1.12.1'

recipe 'aspnet_skeleton::default', 'Deploys the skeleton web app'
