
%w{ pivotal ticket project comment version }.each do |f|
  require File.dirname(__FILE__) + '/provider/' + f + '.rb';
end
