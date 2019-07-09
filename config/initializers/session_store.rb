# frozen_string_literal: true

Rails.application.config.session_store :cookie_store,
                                       key: '_csv_uploader_session',
                                       expire_after: Rails.configuration.x.session_timeout_in_min.minutes
