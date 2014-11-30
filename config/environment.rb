# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Labohp::Application.initialize!

#AmazonTest::Application.initialize!

Amazon::Ecs.options = { 
    :associate_tag => 'takayukiochia-22',
    :AWS_access_key_id => 'AKIAJNHQRNG5FQMK2IBA',
    :AWS_secret_key => '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',
    :country => 'jp',
}