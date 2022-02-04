# for all drupal
class profile::drupal {
  # include drush::drush
  include composer
  drush::drush { 'drush8':
  version => '8',
}
}
