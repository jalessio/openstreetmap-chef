name "git"
description "Role applied to all git servers"

default_attributes(
  :accounts => {
    :users => {
      :bretth => {
        :status => :user,
        :shell => "/usr/bin/git-shell"
      },
      :lonvia => {
        :status => :user,
        :shell => "/usr/bin/git-shell"
      },
      :yellowbkpk => {
        :status => :user,
        :shell => "/usr/bin/git-shell"
      },
      :git => {
        :status => :role,
        :members => [:tomh, :grant, :matt, :lonvia, :yellowbkpk]
      }
    }
  },
  :apache => {
    :mpm => "event",
      :event => {
        :min_spare_threads => 50,
        :max_spare_threads => 150,
        :listen_cores_buckets_ratio => 4
      }
  },
  :git => {
    :host => "git.openstreetmap.org",
    :aliases => ["git.osm.org"]
  }
)

run_list(
  "recipe[git::server]",
  "recipe[git::web]"
)
