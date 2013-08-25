stasi
=====

SSH shell like Gitolite for git and mercurial.


Use:
====

shell - running command from SSH_ORIGINAL_COMMAND
	$ env SSH_ORIGINAL_COMMAND="git-upload-pack 'stasi.git'" build/stasi shell --user franta
	$ env SSH_ORIGINAL_COMMAND="ls -la" build/stasi shell --user franta


verify-config - check syntax of configuration
	$ stasi verify-config --config config.xml


version - print version of stasi.
	$ stasi version


auth - Athorization of user's permission. Access allowed or denied.
	$ stasi auth --repo stasi.git --user franta --access read


auth-update - Updated authorized_keys by config.xml.
	comming soon



## Manage wrapered ~/.ssh/authorized_keys

Format:
- Per line
- command="/usr/bin/stasi shell --user fean",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-dss AAAAB---PiCJA== fean@example.com
