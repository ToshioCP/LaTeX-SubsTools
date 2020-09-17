$:.each do |l|
  if /site_ruby.*x86_64-linux/ =~ l
    @install_dir = l
    break
  end
end

ltx = IO.read("ltx.rb")
IO.write(@install_dir+"/ltx.rb", ltx)

IO.write("install_directory.txt", @install_dir)
