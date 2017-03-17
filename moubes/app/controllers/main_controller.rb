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

  def get_all_usernames
    my_file = File.open("app/fixtures/userlist/userlist.txt")
    ret_arr = my_file.read.split.sort!
    my_file.close
    return ret_arr
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

  def get_average_marks(data_array)
    avg = 0
    for i in 2..data_array.size-1
      data_array[i] = data_array[i].to_i unless data_array[i].match(/[^[:digit:]]+/)
    end
    for i in 2..15
      if Integer === data_array[i]
        avg += data_array[i].to_i
      elsif data_array[i] == "-42"
        avg = avg -42
      elsif data_array[i] == "--"
        avg = avg -1
      elsif data_array[i] == "**"
        avg = avg -2
      end
    end
    for i in 16..21
      if Integer === data_array[i]
        avg += data_array[i].to_i * 2
      elsif data_array[i] == "-42"
        avg = avg -42 * 2
      elsif data_array[i] == "--"
        avg = avg -2
      elsif data_array[i] == "**"
        avg = avg -4
      end
    end
    for i in 22..25
      if Integer === data_array[i]
        avg += data_array[i].to_i * 3
      elsif data_array[i] == "-42"
        avg = avg -42 * 3
      elsif data_array[i] == "--" || data_array[i] == "**"
        avg = avg -3
      end
    end
    bonus = 0
    if Integer === data_array[25]
      avg += data_array[25].to_i * 2
      bonus = 2
    elsif data_array[25] == "-42"
      avg = avg -42
    end
    return (avg.to_f / (38 + bonus)).round(1)
  end

  def get_scores(data_hash)
    score_arr = Array.new()
    if has_cheated(data_hash) == "no"
      score_arr.push(["cheating", 1])
    else
      score_arr.push(["cheating", 0])
    end
    if get_num_validated(data_hash) >= 5
      score_arr.push(["validation", 1])
    else
      score_arr.push(["validation", 0])
    end
    if check_final_exam(data_hash) == 1
      score_arr.push(["final exam", 1])
    else
      score_arr.push(["final exam", 0])
    end
    if check_all_exam(data_hash) == 1
      score_arr.push(["other exams", 1])
    else
      score_arr.push(["other exams", 0])
    end
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
                temp_info << "**"
              end
            end
          end
        else
          temp_info << "--"
        end
      end
    end
    if get_average_marks(temp_info) >= 10
      score_arr.push(["average above 10", 1])
    else
      score_arr.push(["average above 10", 0])
    end
    final_score = 0
    for i in 0..score_arr.size-1
      final_score += score_arr[i][1]
    end
    @final_score = final_score
    return score_arr
  end

  def get_user_marks(username)
    if USERS.include? username
      temp_info = Array.new()
      file = File.read("app/fixtures/userlist/" + username + ".json")
      data_hash = JSON.parse(file)
      temp_info = Array.new()
      temp_info[0] = data_hash['login']
      hold = get_scores(data_hash)
      score = 0
      for i in 0..hold.size-1
        score += hold[i][1]
      end
      temp_info << score.to_s
      for k in 0..PROJECTS.size-1
        if data_hash['projects_users'].any? {|h| h['project']['slug'] == PROJECTS[k]}
          for j in 0..data_hash['projects_users'].size-1
            if data_hash['projects_users'][j]['project']['slug'] == PROJECTS[k]
              if data_hash['projects_users'][j]['final_mark']
                temp_info << data_hash['projects_users'][j]['final_mark'].to_s
              else
                temp_info << "**"
              end
            end
          end
        else
          temp_info << "--"
        end
      end
    end
    return temp_info
  end

  def get_mass_info
    userlist = get_all_usernames
    mass_info = Array.new()
    my_file = File.open("app/fixtures/projectlistdisplay.txt")
    mass_info.push(my_file.read.split)
    for i in 0..userlist.size-1
      temp_info = Array.new()
      temp_info = get_user_marks(userlist[i])
      temp_info << get_average_marks(temp_info)
      mass_info << temp_info
    end
    return mass_info
  end

  def has_cheated(data_hash)
    retval = "no"
    for j in 0..PROJECTS.size-1
      if data_hash['projects_users']
        for i in 0..data_hash['projects_users'].size-1
          if data_hash['projects_users'][i]['project']['slug'] == PROJECTS[j]
            if data_hash['projects_users'][i]['final_mark']
              if data_hash['projects_users'][i]['final_mark'].to_i == -42
                retval = "yes"
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
    for j in 20..23
      if not data_hash['projects_users'].any? {|h| h['project']['slug'] == PROJECTS[j]}
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
    if data_hash['projecs_users']
      for i in 0..data_hash['projects_users'].size-1
        if data_hash['projects_users'][i]['project']['slug'] == PROJECTS[23]
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
    for j in 20..22
      if data_hash['projecs_users']
        for i in 0..data_hash['projects_users'].size-1
          if data_hash['projects_users'][i]['project']['slug'] == PROJECTS[j]
            if data_hash['projects_users'][i]['final_mark']
              if data_hash['projects_users'][i]['final_mark'] >= 25
                return 1
              end
            end
          end
        end
      end
    end
    return 0
  end

  def get_mass_score
    userlist = get_all_usernames
    mass_score = Array.new()
    for i in 0..userlist.size-1
      mass_score.push(get_scores(userlist[i]))
    end
    return mass_score
  end

  def userpage
    @userstest = USERS
    if USERS.include? params[:usernamesearch]
      @can_show = true
      file = File.read("app/fixtures/userlist/" + params[:usernamesearch] + ".json")
      data_hash = JSON.parse(file)
      @first_name = data_hash['first_name']
      @last_name = data_hash['last_name']
      @login = data_hash['login']
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
        @achievements = "none"
        @achiv = "none"
      end
      if data_hash['titles'].any?
        @titles = titler(data_hash)
      else
        @titles = "none"
      end
      if data_hash['partnerships'].any?
        @partnerships = partnerer(data_hash)
      else
        @partnerships = "none"
      end
    else
      @can_show = false
    end
  end

  def allusers
    @mass_info = get_mass_info
    @mass_score = get_mass_score
  end

  def refresh
    @refreshedusers = users_to_JSON
  end

  def show
    render template: "pages/#{params[:page]}"
  end
end
