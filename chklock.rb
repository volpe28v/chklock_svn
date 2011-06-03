#! /usr/bin/ruby
#! /usr/local/bin/ruby
#############################################################################
# svnロック取得者表示スクリプト
#   chklock.rb
#
# 制限事項：
#  (1)デフォルトではカレント以下のファイルに対してのlock情報を表示する
#     指定ディレクトリ以下の情報を表示したい場合は TARGET_PATH を編集すること
#############################################################################

require 'kconv'


# 検索対象パス
TARGET_PATH = './'
                                                                                                                                               
###############################################################################
# 関数定義

# ファイルパスよりロックユーザを取得する
def getLockName( path )
    info = `svn info #{path}`

    url = nil
    if /URL:[ \t]+(.+)\n/ =~ info
        url = $1
    end
    
    sleep 0.1 # 一息                                                                                                  
    lock_info = `svn info #{url}`
    lock_user = nil

    utf_owner = "ロック所有者:".toutf8

    case lock_info
    when /ロック所有者:[ \t]+(.+)\n/
        lock_user = $1
    when /Lock Owner:[ \t]+(.+)\n/
        lock_user = $1
    when /#{utf_owner}[ \t]+(.+)\n/
	lock_user = $1
    else
        lock_user = "unkown"
    end

    return lock_user
end

###############################################################################
# メイン開始

target_path = TARGET_PATH
if ARGV.size > 0
    target_path = ARGV[0]
end
   
status_lines = `svn status -u #{target_path}`.split("\n")

# ロック済みのファイル情報を取得する
locked_other = []
locked_own   = []
edit_own   = []
add_own   = []
status_lines.each{ |line|
    case line
    when / O /
        locked_other.push(line)
    when / K /
        locked_own.push(line)
    when /M /
        edit_own.push(line)
    when /A /
	    add_own.push(line)
    end
}

# 他のユーザがロックしているユーザ名を取得する
locked_result = Hash.new
locked_other.each{ |line|
    edit_mark = "  "
    if /M / =~ line
        edit_mark = "* "
    end

    path = line.split(" ")[-1]
    short_path = path.sub(target_path,'')
    locked_result[short_path] = edit_mark + getLockName(path)
}

# 自分がロックしているユーザ名を取得する
locked_own.each{ |line|
    edit_mark = "  "
    if /M / =~ line
        edit_mark = "* "
    end

    path = line.split(" ")[-1]
    short_path = path.sub(target_path,'')
    locked_result[short_path] = edit_mark + getLockName(path)
    sleep 0.1 # 一息                                                                                                  
}

# 自分がロックしないで編集しているファイルを取得
edit_own.each{ |line|
    path = line.split(" ")[-1]
    short_path = path.sub(target_path,'')
    locked_result[short_path] = "*"
}

# 追加中のファイルを取得
add_own.each{ |line|
    path = line.split(" ")[-1]
    short_path = path.sub(target_path,'')
    locked_result[short_path] = "+"
}

# 結果出力 
locked_result.to_a.sort{|a,b| (a[1] <=> b[1])*2 + (a[0] <=> b[0]) }.each{ |one_result|
    printf(" %-10s %s\n",one_result[1],one_result[0])
}

