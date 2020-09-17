@install_dir = IO.read("install_directory.txt")
File.delete(@install_dir+"/ltx.rb")

File.delete("install_directory.txt")

