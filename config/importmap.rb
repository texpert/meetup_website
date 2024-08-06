# Pin npm packages by running ./bin/importmap

pin "application"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "trix"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# bin/importmap pin @popperjs/core@2.11.8/+esm --from jsdelivr and then rename the downloaded file removing the +
pin "@popperjs/core", to: "@popperjs--core--esm.js" # @2.11.8
pin "bootstrap" # @5.3.3
pin_all_from "app/javascript/controllers", under: "controllers"
