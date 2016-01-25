#!/bin/sh

MATTERMOST_HOST=mattermost-dev
MATTERMOST_MYSQL_USER=mmuser
MATTERMOST_MYSQL_PASSWD=mostest
MATTERMOST_MYSQL_DATABASE=mattermost_test

READ_CMD="docker exec ${MATTERMOST_HOST} env MYSQL_PWD=${MATTERMOST_MYSQL_PASSWD} mysql --user ${MATTERMOST_MYSQL_USER} ${MATTERMOST_MYSQL_DATABASE} -t -e"

PROGNAME=$(basename $0)
VERSION="1.0"

usage() {
    echo "Usage: $PROGNAME COMMAND [Options]"
    echo
    echo "COMMAND:"
    echo "  channellist"
    echo "  userlist"
    echo "  channelusers [chanel name]"
    echo "  channelmessages [chanel name]"
    exit 1
}

for OPT in "$@"
do
    case "$OPT" in
        '-h'|'--help' )
            usage
            exit 1
            ;;
        '--version' )
            echo $VERSION
            exit 1
            ;;
        'channellist' )
            if [ $# != 1 ]; then
                echo "$PROGNAME: illegal option -- $2" 1>&2
		usage
                exit 1
            fi
            ${READ_CMD} "SET NAMES utf8; select DisplayName, Type, TotalMsgCount, count(UserId) from ChannelMembers cm inner join Channels c on cm.ChannelId = c.Id group by ChannelId order by DisplayName;"
	    exit
            ;;
        'userlist' )
            if [ $# != 1 ]; then
                echo "$PROGNAME: illegal option -- $2" 1>&2
		usage
                exit 1
            fi
            ${READ_CMD} "SET NAMES utf8; select Username,NickName,Email from Users order by Username;"
	    exit
            ;;
        'channelusers' )
            if [ $# != 2 ]; then
                echo "$PROGNAME: illegal option -- $2" 1>&2
		usage
                exit 1
            fi
	    shift
            ${READ_CMD} "SET NAMES utf8; select c.DisplayName, u.Username from Channels c inner join (ChannelMembers cm inner join Users u on cm.UserId = u.Id) on cm.ChannelId = c.Id where c.Name = '$1' order by u.Username;"
	    exit
            ;;
        'channelmessages' )
            if [ $# != 2 ]; then
                echo "$PROGNAME: illegal option -- $2" 1>&2
		usage
                exit 1
            fi
	    shift
            ${READ_CMD} "SET NAMES utf8; select c.DisplayName, u.UserName, p.Message from Channels c inner join (Posts p inner join Users u on p.UserId = u.Id) on p.ChannelId = c.Id  where c.DisplayName = '$1' order by p.CreateAt;" | sed 's/          *|$/|/' | sed 's/----------*+$/|/g'
	    exit
            ;;
        *)
            echo "$PROGNAME: illegal option -- $2" 1>&2
	    usage
	    exit 1
            ;;
    esac
done

usage
exit 1
