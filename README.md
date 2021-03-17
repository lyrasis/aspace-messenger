# ASpace Messenger

Post messages from ArchivesSpace to HTTP urls (webhooks) on event targets.

```ruby
# PLUGIN CFG
AppConfig[:aspace_messenger] = {
  on_startup: {
    app: 'frontend',
    # app: 'backend', 'frontend', 'public', etc. choose 1
    context: {},
    # context (anything you add here can be made available to payload) i.e.
    # context: {
    #   name: 'my_archivesspace',
    #   url: AppConfig[:frontend_proxy_url]
    # },
    # context can also be a proc: context: ->(json) { { title: json['title'] } }
    enabled: false,
    # enabled: true (must be true to send)
    payload: nil,
    # payload: ->(context) { JSON.generate({ text: "ArchivesSpace (#{context[:name]}) is firing up: #{Time.now}" }) }
    # payload: ->(context) {
    #   JSON.generate({
    #     type: 'mrkdwn',
    #     text: "ArchivesSpace <#{context[:url]}|#{context[:name]}> has started up: #{Time.now}"
    #   })
    # }
    url: nil
    # https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
    # ENV.fetch('ASPACE_SLACK_WEBHOOK_URL')
  },
  # TODO: not implemented yet ...
  on_delete: [
    {
      jsonmodel_type: 'resource',
      # jsonmodel_type: record type filter, must match to send message
      # other options as previously described
    }
  ]
}
```

And for a more concise example:

```ruby
AppConfig[:plugins] << 'aspace-messenger'
AppConfig[:aspace_messenger] = {
  on_startup: {
    app: 'frontend',
    context: {
      name: 'DTS',
      url: AppConfig[:frontend_proxy_url]
    },
    enabled: true,
    payload: lambda { |context|
      JSON.generate({
                      type: 'mrkdwn',
                      text: "ArchivesSpace <#{context[:url]}|#{context[:name]}> has started up: #{Time.now}"
                    })
    },
    url: ENV.fetch('ASPACE_SLACK_WEBHOOK_URL')
  }
}
```
