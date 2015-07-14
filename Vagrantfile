
Vagrant.configure(2) do |config|
	config.vm.box = 'precise64'
	config.vm.box_url = 'https://s3.amazonaws.com/infrastructure-cdn.xs.fi/packages/vagrant-box/precise64.box'

	config.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
	end

	config.vm.define :master, primary: true do |master|
		master.vm.network 'private_network', ip: '192.168.56.169'
	end
end
