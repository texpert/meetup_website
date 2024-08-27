// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "controllers"
import "@hotwired/turbo-rails"
import "@popperjs/core"
import "bootstrap"

import "@fortawesome/fontawesome-free"
FontAwesome.config.mutateApproach = 'sync' // prevents from flickering
import { far } from "@fortawesome/free-regular-svg-icons"
import { fas } from "@fortawesome/free-solid-svg-icons"
import { fab } from "@fortawesome/free-brands-svg-icons"
import { library } from "@fortawesome/fontawesome-svg-core"
library.add(far, fas, fab)
