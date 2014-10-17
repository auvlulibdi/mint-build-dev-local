# On branch mint-ltu
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
git add package.xml
git add pom.xml
git add src/main/config/home/system-config.json
git add src/main/config/server/tf_env.sh
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#	pom.xml_
git add runMe.sh
#	src/main/config/server/tf_env.sh_
# no changes added to commit (use "git add" and/or "git commit -a")

git commit -m 'Changes to make mint work like local-dev build (1.7-SNAPSHOT) but NLA-lookup still broken'

