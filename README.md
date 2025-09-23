# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version 3.4.5
* Rails version 8.0.3

## Dependencies

### Checking for outdated or vulnerable JS packages:

Importmap for Rails provides two commands to check your pinned packages:

    ./bin/importmap outdated checks the NPM registry for new versions
    ./bin/importmap audit checks the NPM registry for known security issues

### Updating JS packages

    ./bin/importmap update

If `update` doesn't work, you can pin the new version:

    ./bin/importmap pin bootstrap@5.3.7

### Updating CSS packages

Download new packages and store them into the `vendor/assets` folder

## Configuration

## Database creation

## Database initialization

## How to run the test suite

## Services (job queues, cache servers, search engines, etc.)

## Deployment instructions
