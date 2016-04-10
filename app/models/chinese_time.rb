class ChineseTime

  def self.display(datetime)
    str = ""
    str += "#{datetime.month}月"
    str += "#{datetime.day}日"
    str += "，"
    str += ChineseTime.display_time_only(datetime)
  end

  def self.display_time_only(datetime)
    str = datetime.strftime("%p%l:%M")
    str.gsub(" ", "").gsub("AM", "上午").gsub("PM", "下午")
  end

end