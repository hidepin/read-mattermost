#!/bin/sh

MATTERMOST_HOST=mattermost-dev
MATTERMOST_MYSQL_USER=mmuser
MATTERMOST_MYSQL_PASSWD=mostest
MATTERMOST_MYSQL_DATABASE=mattermost_test

READ_CMD="docker exec ${MATTERMOST_HOST} mysql --user ${MATTERMOST_MYSQL_USER} --password=${MATTERMOST_MYSQL_PASSWD} ${MATTERMOST_MYSQL_DATABASE} -t -e"

${READ_CMD} "SET NAMES utf8; show tables;"
${READ_CMD} "SET NAMES utf8; select DisplayName, Type, TotalMsgCount, count(UserId) from ChannelMembers cm inner join Channels c on cm.ChannelId = c.Id group by ChannelId;"
${READ_CMD} "SET NAMES utf8; select Username,NickName,Email from Users;"
${READ_CMD} "SET NAMES utf8; select c.Name, u.Username from Channels c inner join (ChannelMembers cm inner join Users u on cm.UserId = u.Id) on cm.ChannelId = c.Id;"
${READ_CMD} "SET NAMES utf8; select * from Posts;" | head
${READ_CMD} "SET NAMES utf8; select u.UserName, c.Name, p.Message from Channels c inner join (Posts p inner join Users u on p.UserId = u.Id) on p.ChannelId = c.Id order by p.CreateAt;" | sed 's/[ ]*|$/|/'
