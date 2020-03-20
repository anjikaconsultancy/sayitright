module DisplayHelper

  #build url parameters from current path - this maintains any path structure and parameters
  def current_url(new_params={})
    display_url(@paths,new_params)
  end
  
  #merge url parameters
  def merge_url(new_params={})
    #we need to inject @paths into the url as it does not pull it in automatically
    display_url(@paths,params.merge(new_params))
  end
  
  def pagination
   {
    :page=>params["page"].presence.to_i || 0,
    :pages=>search['matches']/10,
    :total=>search['matches'],
    :results=>search['results'].count
   }
  end
  
end
