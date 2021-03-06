class MainController < ApplicationController
  UID = "efed4ffd11a9e8bf9d09f735c5f63fc0c8ce9a5cd50dbcdfcc95f523e728e71a"
  SECRET = "e34de41c45d7f895c8d7387108d0336c1d6f485e82ffc0ef98481ae6033761f1"
  temp_file = File.open("app/fixtures/projectlist.txt")
  PROJECTS = temp_file.read.split
  temp_file2 = File.open("app/fixtures/userlist/userlist.txt")
  USERS = temp_file2.read.split

  def token_get(username)
    client = OAuth2::Client.new(UID, SECRET, site: "https://api.intra.42.fr")
    token = client.client_credentials.get_token
    response = token.get("/v2/users/" + username)
  end

  def get_all_usernames
    my_file = File.open("app/fixtures/userlist/userlist.txt")
    ret_arr = my_file.read.split.sort!
    my_file.close
    return ret_arr
  end

  def save_user_pic(username)
    filename = 'app/assets/images/userpics/' + username + '.png'
    open(filename, 'wb') do |file|
      begin
        file << open('http://cdn.intra.42.fr/users/small_' + username + '.jpg').read
      rescue OpenURI::HTTPError => ex
        File.delete(file)
      end
    end
  end

  def save_all_pics
    user_list = get_all_usernames
    for i in 0..user_list.size-1
      save_user_pic(user_list[i])
    end
  end

  def get_project_display()
    my_file = File.open("app/fixtures/projectlistdisplay.txt")
    my_file.read.split
  end

  def change_status(username, status)
	  file = File.read('app/fixtures/info/acceptance.txt').split.sort!
	  edited = false
	  outarray = Array.new
	  for i in 0..file.size-1
		  file[i] = file[i].split(';')
			if file[i][0] == username
				edited = true
				outarray[i] = username + ';' + status
			else
				outarray[i] = file[i][0] + ';' + file[i][1]
			end
	  end
	  open('app/fixtures/info/acceptance.txt', 'w') do |f|
		  for i in 0..file.size-1
				f.puts(outarray[i])
		  end
		  if edited == false
				f.puts(username + ';' + status)
		  end
	  end
  end

  def validator(data_hash)
    ret_arr = Array.new()
    for j in 0..PROJECTS.size-1
      for i in 0..data_hash['projects_users'].size-1
        if data_hash['projects_users'][i]['project']['slug'] == PROJECTS[j]
          if data_hash['projects_users'][i]['final_mark']
            if data_hash['projects_users'][i]['final_mark'] > 0
              temp_arr = Array.new()
              hold = data_hash['projects_users'][i]['project']['name']
              hold2 = data_hash['projects_users'][i]['final_mark']
              temp_arr.push(hold)
              temp_arr.push(hold2)
              ret_arr.push(temp_arr)
            end
          end
        end
      end
    end
    return ret_arr
  end

  def invalidator(data_hash)
    ret_arr = Array.new()
    for j in 0..PROJECTS.size-1
      for i in 0..data_hash['projects_users'].size-1
        if data_hash['projects_users'][i]['project']['slug'] == PROJECTS[j]
          if data_hash['projects_users'][i]['final_mark'] == false || data_hash['projects_users'][i]['final_mark'] == 0
            hold = data_hash['projects_users'][i]['project']['name']
            ret_arr.push(hold)
          end
        end
      end
    end
    return ret_arr
  end

  def unregistered(data_hash)
    ret_arr = Array.new()
    for i in 0..PROJECTS.size-1
      if not data_hash['projects_users'].any? {|h| h['project']['slug'] == PROJECTS[i]}
        hold = PROJECTS[i]
        ret_arr.push(hold)
      end
    end
    return ret_arr
  end

  def unmarked(data_hash)
    ret_arr = Array.new()
    for i in 0..PROJECTS.size-1
      for j in 0..data_hash['projects_users'].size-1
        if (data_hash['projects_users'][j]['project']['slug'] <=> PROJECTS[i]) == 0
          if data_hash['projects_users'][j]['final_mark'] == NIL
            hold = data_hash['projects_users'][j]['project']['name']
            ret_arr.push(hold)
          end
        end
      end
    end
    return ret_arr
  end

  def achiever(data_hash)
    ret_arr = Array.new()
    for i in 0..data_hash['achievements'].size-1
      ret_arr.push(data_hash['achievements'][i]['name'])
      ret_arr[i].insert(0, "____(")
      ret_arr[i] << ")"
    end
    return ret_arr.to_sentence
  end

  def titler(data_hash)
    ret_arr = Array.new()
    for i in 0..data_hash['titles'].size-1
      ret_arr.push(data_hash['titles'][i]['name'])
      ret_arr[i].insert(0, "____(")
      ret_arr[i] << ")"
    end
    return ret_arr.to_sentence
  end

  def partnerer(data_hash)
    ret_arr = Array.new()
    for i in 0..data_hash['partnerships'].size-1
      ret_arr.push(data_hash['partnerships'][i]['name'])
      ret_arr[i].insert(0, "____(")
      ret_arr[i] << ")"
    end
    return ret_arr.to_sentence
  end

  def users_to_JSON
    usernames = get_all_usernames
    for i in 0..usernames.size-1
      hold = token_get(usernames[i])
      data_hash = hold.parsed
      File.open("app/fixtures/userlist/" + usernames[i] + ".json","w") do |f|
        f.write(data_hash.to_json)
      end
    end
    return usernames
  end

  def get_all_user_info_arr
    userlist = get_all_usernames
    mass_info = Array.new()
    for i in 0..userlist.size-1
      file = File.read("app/fixtures/userlist/" + userlist[i] + ".json")
      data_hash = JSON.parse(file)
      mass_info[i][0] = data_hash['login']
      for k in 0..PROJECTS.size-1
        mass_info[i][k + 1] = PROJECTS[k]
      end
    end
    return mass_info
  end

  def get_average_marks(data_hash)
		temp_info = Array.new()
	  for k in 0..PROJECTS.size-1
			if data_hash['projects_users']
			  if data_hash['projects_users'].any? {|h| h['project']['slug'] == PROJECTS[k]}
				  for j in 0..data_hash['projects_users'].size-1
					  if data_hash['projects_users'][j]['project']['slug'] == PROJECTS[k]
						  if data_hash['projects_users'][j]['final_mark']
							  temp_info << data_hash['projects_users'][j]['final_mark'].to_s
						  else
							  temp_info << '-2'
						  end
					  end
				  end
			  else
				  temp_info << '-1'
			  end
			end
	  end

    avg = 0
    for i in 2..temp_info.size-1
      temp_info[i] = temp_info[i].to_i unless temp_info[i].match(/[^[:digit:]]+/)
    end
    for i in 2..15
      if Integer === temp_info[i]
        avg += temp_info[i].to_i
      elsif temp_info[i] == '-42'
        avg = avg -42
      elsif temp_info[i] == '1'
        avg = avg -1
      elsif temp_info[i] == '-2'
        avg = avg -2
      end
    end
    for i in 16..21
      if Integer === temp_info[i]
        avg += temp_info[i].to_i * 2
      elsif temp_info[i] == '-42'
        avg = avg -42 * 2
      elsif temp_info[i] == '-1'
        avg = avg -2
      elsif temp_info[i] == '-2'
        avg = avg -4
      end
    end
    for i in 22..25
      if Integer === temp_info[i]
        avg += temp_info[i].to_i * 3
      elsif temp_info[i] == '-42'
        avg = avg -42 * 3
      elsif temp_info[i] == '-1' || temp_info[i] == '-2'
        avg = avg -3
      end
    end
    bonus = 0
    if Integer === temp_info[25]
      avg += temp_info[25].to_i * 2
      bonus = 2
    elsif temp_info[25] == '-42'
      avg = avg -42
    end
    return (avg.to_f / (38 + bonus)).round(1)
  end

  def get_user_attendance(username)
	  file = File.read('app/fixtures/info/attend.txt').split.sort!
	  for i in 0..file.size-1
		  file[i] = file[i].split(';')
	  end
	  @file = file
	  for i in 0..file.size-1
		  if file[i][0] == username
			  return file[i][1]
		  end
	  end
	  return 0
  end

  def get_user_p2p(username)
	  file = File.read('app/fixtures/info/p2p.txt').split.sort!
	  for i in 0..file.size-1
		  file[i] = file[i].split(';')
	  end
	  @file = file
	  for i in 0..file.size-1
		  if file[i][0] == username
			  return file[i][1]
		  end
	  end
	  return 0
  end

  def get_user_megatron(username)
	  file = File.read('app/fixtures/info/megatron.txt').split.sort!
	  for i in 0..file.size-1
		  file[i] = file[i].split(';')
	  end
	  @file = file
	  for i in 0..file.size-1
		  if file[i][0] == username
			  return file[i][1]
		  end
	  end
	  return 0
  end

  def get_scores(data_hash)
    score_arr = Array.new()
    (has_cheated(data_hash) == 'no') ? score_arr.push(['cheating', 1]) : score_arr.push(['cheating', 0])
    (get_num_validated(data_hash) >= 5) ? score_arr.push(['validation', 1]) : score_arr.push(['validation', 0])
    (check_final_exam(data_hash) == 1) ? score_arr.push(['final exam', 1]) : score_arr.push(['final exam', 0])
    (check_all_exam(data_hash) == 1) ? score_arr.push(['other exams', 1]) : score_arr.push(['other exams', 0])
    temp_info = Array.new()
    temp_info[0] = data_hash['login']
    for k in 0..PROJECTS.size-1
      if data_hash['projecs_users']
        if data_hash['projects_users'].any? {|h| h['project']['slug'] == PROJECTS[k]}
          for j in 0..data_hash['projects_users'].size-1
            if data_hash['projects_users'][j]['project']['slug'] == PROJECTS[k]
              if data_hash['projects_users'][j]['final_mark']
                temp_info << data_hash['projects_users'][j]['final_mark'].to_s
              else
                temp_info << '-2'
              end
            end
          end
        else
          temp_info << '-1'
        end
      end
    end
    (get_average_marks(data_hash) >= 10) ?
		    score_arr.push(['average above 10', 1]) :
		    score_arr.push(['average above 10', 0])
    (data_hash['cursus_users'][0]['level'] >= 1) ?
		    score_arr.push(['level above/equal 1', 1]) :
		    score_arr.push(['level above/equal 1', 0])
    final_score = 0
    for i in 0..score_arr.size-1
      final_score += score_arr[i][1]
    end
    if get_user_attendance(data_hash['login']).to_i > 23
	    score_arr.push(['Attendance above 23', 1])
			final_score += 1
    elsif get_user_attendance(data_hash['login']).to_i > 10
	    score_arr.push(['Attendance above 23', 0])
    else
			final_score -= 1
	    score_arr.push(['Attendance above 23', -1])
    end
    if get_user_megatron(data_hash['login']).to_i > 5
	    score_arr.push(['Megatron above 5', 1])
	    final_score += 1
    else
	    score_arr.push(['Megatron above 5', 0])
    end
    if get_user_p2p(data_hash['login']).to_i > 45
	    score_arr.push(['P2P above 45', 1])
	    final_score += 1
    else
	    score_arr.push(['P2P above 45', 0])
    end
    score_arr.insert(0, ['total', final_score])
    return score_arr
  end


  def get_user_marks(username)
    if USERS.include? username
      temp_info = Array.new()
      file = File.read("app/fixtures/userlist/" + username + ".json")
      data_hash = JSON.parse(file)
      temp_info = Array.new()
      temp_info[0] = data_hash['login']
      score = get_scores(data_hash)
      temp_info << score[0][1]
      temp_info << data_hash['cursus_users'][0]['level'].round(2)
      for k in 0..PROJECTS.size-1
        if data_hash['projects_users'].any? {|h| h['project']['slug'] == PROJECTS[k]}
          for j in 0..data_hash['projects_users'].size-1
            if data_hash['projects_users'][j]['project']['slug'] == PROJECTS[k]
              if data_hash['projects_users'][j]['final_mark']
                temp_info << data_hash['projects_users'][j]['final_mark'].to_s
              else
                temp_info << '-2'
              end
            end
          end
        else
          temp_info << '-1'
        end
      end
      temp_info << get_average_marks(data_hash).round(1)
			for i in 1..score.size-4
				temp_info << score[i][1]
			end
			temp_info << get_user_attendance(data_hash['login'])
      temp_info << get_user_megatron(data_hash['login'])
      temp_info << get_user_p2p(data_hash['login'])
			temp_info << get_num_validated(data_hash)
			temp_info << get_num_exams_validated(data_hash)
			temp_info << (unmarked(data_hash).size + unregistered(data_hash).size - get_num_exams_missed(data_hash))
			temp_info << get_num_exams_missed(data_hash)
      status_file = File.read('app/fixtures/info/acceptance.txt').split.sort!
      edited = false
      for i in 0..status_file.size-1
				cur_status = status_file[i].split(';')
				if cur_status[0] == username
					temp_info << cur_status[1]
					edited = true
				end
      end
			if edited == false
				temp_info << 'N/A'
			end
    end
    pod_file = File.read('app/fixtures/info/pods.txt')
    edited = false
    pod_file = pod_file.split.map do |tri|
	    name, points, pod = tri.split(';')
	    if data_hash['login']
		    if name == data_hash['login']
			    temp_info << pod
			    temp_info << points
			    edited = true
		    end
	    end
    end
    if edited == false
	    temp_info << '??'
			temp_info << '??'
    end
    return temp_info
  end

  def get_mass_info(sort_num)
    userlist = get_all_usernames
    mass_info = Array.new()
    for i in 0..userlist.size-1
      temp_info = Array.new()
      temp_info = get_user_marks(userlist[i])
      mass_info << temp_info
    end
    if (sort_num == 0 || sort_num == 43 || sort_num == 42)
	    mass_info.sort_by!{|k| k[sort_num]}
    else
			mass_info.sort_by!{|k| k[sort_num].to_f}.reverse!
    end
    @test = mass_info
    mass_info.insert(0, get_project_display)
    return mass_info
  end

  def has_cheated(data_hash)
    retval = 'no'
    for j in 0..PROJECTS.size-1
      if data_hash['projects_users']
        for i in 0..data_hash['projects_users'].size-1
          if data_hash['projects_users'][i]['project']['slug'] == PROJECTS[j]
            if data_hash['projects_users'][i]['final_mark']
              if data_hash['projects_users'][i]['final_mark'].to_i == -42
                retval = 'yes'
              end
            end
          end
        end
      end
    end
    return retval
  end

  def get_num_validated(data_hash)
    totalval = 0
    for j in 0..PROJECTS.size-1
      if data_hash['projects_users']
        for i in 0..data_hash['projects_users'].size-1
          if (j < 20 || j == 24)
            if data_hash['projects_users'][i]['project']['slug'] == PROJECTS[j]
              if data_hash['projects_users'][i]['final_mark']
                if data_hash['projects_users'][i]['final_mark'] >= 25
                  totalval += 1
                end
              end
            end
          end
        end
      end
    end
    return totalval
  end

  def get_num_exams_validated(data_hash)
    totalval = 0
    for j in 20..23
      for i in 0..data_hash['projects_users'].size-1
        if data_hash['projects_users'][i]['project']['slug'] == PROJECTS[j]
          if data_hash['projects_users'][i]['final_mark']
            if data_hash['projects_users'][i]['final_mark'] >= 25
              totalval += 1
            end
          end
        end
      end
    end
    return totalval
  end

  def get_num_exams_missed(data_hash)
    count = 0
    #exams = ['bootcamp-joburg-exam-00', 'bootcamp-joburg-exam-01', 'bootcamp-joburg-exam-02']
    for j in 20..23
	    unless data_hash['projects_users'].any? { |h| h['project']['slug'] == PROJECTS[j] }
		    count += 1
	    end
      for i in 0..data_hash['projects_users'].size-1
        if data_hash['projects_users'][i]['project']['slug'] == PROJECTS[j]
          if data_hash['projects_users'][i]['final_mark'] == NIL
            count += 1
          end
        end
      end
    end
    return count
  end

  def check_final_exam(data_hash)
    if data_hash['projects_users']
      for i in 0..data_hash['projects_users'].size-1
        if data_hash['projects_users'][i]['project']['slug'] == 'bootcamp-joburg-final-exam'
          if data_hash['projects_users'][i]['final_mark']
            if data_hash['projects_users'][i]['final_mark'] >= 25
              return 1
            end
          end
        end
      end
    end
    return 0
  end

  def check_all_exam(data_hash)
		exams = ['bootcamp-joburg-exam-00', 'bootcamp-joburg-exam-01', 'bootcamp-joburg-exam-02']
	  if data_hash['projects_users']
		  for i in 0..data_hash['projects_users'].size-1
			  if exams.include? data_hash['projects_users'][i]['project']['slug']
				  if data_hash['projects_users'][i]['final_mark']
					  if data_hash['projects_users'][i]['final_mark'] >= 25
						  return 1
					  end
				  end
        end
      end
    end
    return 0
  end

  def write_csv(mass_arr)
	  skipvals = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 27, 29, 30, 31, 32, 33, 34, 38, 39, 40, 41, 42, 43, 44, 99]
	  open('app/fixtures/all_users.csv', 'w') do |f|
		  hold_str = Array.new
		  hold_str << mass_arr[0][0]
			for i in 1..mass_arr[0].size-1
				next if skipvals.include?(i)
				hold_str << ';' + mass_arr[0][i]
			end
		  hold_str = hold_str.join
		  f.puts(hold_str)
		  @test = hold_str
		  for i in 1..mass_arr.size-1
				hold_str = Array.new
				hold_str << mass_arr[i][0]
				for j in 1..mass_arr[i].size-1
					next if skipvals.include?(j)
					hold_str << ';' + mass_arr[i][j].to_s
				end
				hold_str = hold_str.join
				f.puts(hold_str)
		  end
	  end
  end

  def download_csv
		write_csv(get_mass_info(0))
	  send_file('/Users/Havengul/Work/Internship/Moubes/moubes/app/fixtures/all_users.csv')
  end


  def userpage
    @userstest = USERS
    if USERS.include? params[:usernamesearch]
      @can_show = true
      file = File.read("app/fixtures/userlist/" + params[:usernamesearch] + ".json")
      data_hash = JSON.parse(file)
      if params[:status]
				change_status(data_hash['login'], params[:status])
      end
      @first_name = data_hash['first_name']
      @last_name = data_hash['last_name']
      @login = data_hash['login']
      @project_display = get_project_display
      @user_info = get_user_marks(data_hash['login'])
      @campus_name = data_hash['campus'][0]['name']
      @intra_link = data_hash['url']
      @level = data_hash['cursus_users'][0]['level']
      @correction_points = data_hash['correction_point']
      @wallet = data_hash['wallet']
      @validated_arr = validator(data_hash)
      @invalidated_arr = invalidator(data_hash)
      @unregistered_arr = unregistered(data_hash)
      @unmarked_arr = unmarked(data_hash)
      @num_validated = get_num_validated(data_hash)
      @num_exams_validated = get_num_exams_validated(data_hash)
      @num_missed = @unregistered_arr.size + @unmarked_arr.size
      @num_exam_missed = get_num_exams_missed(data_hash)
      @has_cheated = has_cheated(data_hash)
      @score_arr = get_scores(data_hash)
      if data_hash['achievements'].any?
        @achievements = achiever(data_hash)
      else
        @achievements = 'none'
        @achiv = 'none'
      end
      if data_hash['titles'].any?
        @titles = titler(data_hash)
      else
        @titles = 'none'
      end
      if data_hash['partnerships'].any?
        @partnerships = partnerer(data_hash)
      else
        @partnerships = 'none'
      end
    else
      @can_show = false
    end
  end

  def allusers
    @mass_info = get_mass_info(params[:sortby].to_i)
  end

  def refresh
    save_all_pics
    @refreshedusers = users_to_JSON
  end

  def show
    render template: "pages/#{params[:page]}"
  end
end
