# Reopen core Ruby classes here and add some custom methods.
class String
  # Convenience method for converting strings to UTF-16LE for wide character
  # functions that require it.
  #--
  # TODO: Use a refinement.
  def wincode
    (tr(File::SEPARATOR, File::ALT_SEPARATOR) + 0.chr).encode('UTF-16LE')
  end
end
