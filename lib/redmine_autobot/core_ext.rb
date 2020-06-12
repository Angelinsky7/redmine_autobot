class String

  def collection_split_reject_strip
    self.split(',').reject{|t| t.empty?}.collect{|t| t.strip}
  end

  def collection_split_reject_collect_join
    self.split(',').reject{|t| t.empty?}.collect{|t| "'#{t.strip}'"}.join(', ')
  end

end