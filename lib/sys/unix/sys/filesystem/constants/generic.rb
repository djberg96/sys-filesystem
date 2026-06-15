# frozen_string_literal: true

module Sys
  class Filesystem
    module Constants
      MNT_RDONLY = 0x00000001
      MNT_NOSUID = 0x00000002

      MNT_VISFLAGMASK = MNT_RDONLY | MNT_NOSUID

      MNT_FORCE = 1

      MOUNT_OPTION_NAMES = {
        MNT_RDONLY => 'read-only',
        MNT_NOSUID => 'nosuid'
      }.freeze
    end
  end
end
