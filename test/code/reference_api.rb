require 'sinatra/base'

module API
  class ReferenceAPI < Sinatra::Base 

    ##
    # :method: get(/:grid5000-resource/versions[.:format])
    #
    # :call-seq:
    #   GET /:grid5000-resource/versions[.:format]
    # 
    # Get the list of all versions of a particular resource.
    #
    # == URI parameters
    # <tt>grid5000-resource</tt>:: the URI of the grid5000 resource.
    # <tt>format</tt>:: the requested format [json,xml] if you do not use the <tt>Accept</tt> header in your HTTP request.
    # 
    # == Query parameters
    # <tt>limit</tt>:: maximum number of versions to return.
    #
    # == Content-Types
    # <tt>application/json</tt>:: JSON
    # <tt>application/xml</tt>:: XML
    #
    # == Status codes
    # <tt>200</tt>:: OK, the response contains the list of the versions of the requested grid5000 resource.
    # <tt>404</tt>:: the requested grid5000 resource cannot be found.
    # <tt>406</tt>:: the requested format is not available.
    # 
    # == Usage
    # Get the 2 latest versions of the Rennes site:
    #     GET /grid5000/sites/rennes/versions?limit=2 HTTP/1.1
    #     Accept: application/json
    #
    #
    #     HTTP/1.1 200 OK                                                                  
    #     Date: Tue, 17 Mar 2009 13:41:45 GMT                                              
    #     ETag: "0745dc6351cdd00919e8611f8f6952eb48fc9b56"                                 
    #     Cache-Control: public, max-age=120                                               
    #     Age: 0                                                                           
    #     Content-Length: 496                                                              
    #     Content-Type: application/json;charset=utf-8                                     
    #     [                                                                                
    #       {                                                                              
    #         "message": "Added network interfaces to helios and azur clusters.",          
    #         "uri": "\/sites\/versions\/29202872636a3f4023b956cc7bba38c15850ec9f",        
    #         "date": "Tue, 17 Mar 2009 09:28:27 GMT",                                     
    #         "id": "29202872636a3f4023b956cc7bba38c15850ec9f"                             
    #       },                                                                             
    #       {                                                                              
    #         "message": "Added network interfaces to genepi nodes.",                      
    #         "uri": "\/sites\/versions\/7edfbafddb08beb8251c543c5c96e5d736bf23fa",        
    #         "date": "Tue, 17 Mar 2009 09:17:48 GMT",                                     
    #         "id": "7edfbafddb08beb8251c543c5c96e5d736bf23fa"                             
    #       }                                                                              
    #     ]                                                                                
    #
    
    #
    get '*/versions.:format' do |resource_uri, format|

    end
    
    ##
    # :method: get(/:grid5000-resource/versions/:version[.:format])
    # 
    # :call-seq:
    #   GET /:grid5000-resource/versions/:version[.:format]
    # 
    # Get info about a specific version.
    #
    # == URI parameters
    # <tt>grid5000-resource</tt>:: the URI of the grid5000 resource.
    # <tt>version</tt>:: the version id (40 characters long) or a UNIX timestamp.
    #
    # == Content-Types
    # <tt>application/json</tt>:: JSON
    # <tt>application/xml</tt>:: XML
    # 
    # == Status codes
    # <tt>200</tt>:: OK.
    # <tt>404</tt>:: the requested grid5000 resource cannot be found, or the requested version does not exist.
    # <tt>406</tt>:: the requested format is not available.
    #
    
    #
    get '*/versions/:version.:format' do |resource_uri, version, format|     

    end
    
    ##
    # :method: get(/:grid5000-resource[.:format])
    #
    # :call-seq:
    #   GET /:grid5000-resource[.:format]
    # 
    # Get a specific version of a Grid5000 resource.
    #
    # == URI parameters
    # <tt>grid5000-resource</tt>:: the URI of the grid5000 resource.
    #
    # == Query parameters
    # <tt>version</tt>:: the requested version. It can be a version id (40 characters), 
    #                    or a UNIX timestamp [default=empty (most recent version is used)].
    # <tt>depth</tt>:: the number of nested sub-resources to resolve [default=1].
    # <tt>resolve</tt>:: a list of comma separated sub-resources names to resolve (to be used with the +depth+ parameter) [default=all].
    #
    # == Content-Types
    # <tt>application/json</tt>:: JSON
    # <tt>application/xml</tt>:: XML
    # <tt>application/zip</tt>:: the ZIP format will return a zip archive containing the set of directories and files corresponding to the required data, with all its sub-resources.
    # 
    # == Status codes
    # <tt>200</tt>:: OK, the response contains the description of the resource as it was at the requested version.
    # <tt>404</tt>:: the requested grid5000 resource cannot be found, or the requested version does not exist.
    # <tt>406</tt>:: Returns 406 if the requested format is not available.
    #
    
    #
    get '*.:format' do |resource_uri, format|

    end
    
    private        
    
    def metadata_for_commit(commit, resource_uri)
      { 
        'uid' => commit.id,
        'date' => commit.committed_date.httpdate,
        'message' => commit.message,
        'author' => commit.author,
        'type' => 'version',
        'links' => [
          {'rel' => 'self', 'href' => "#{resource_uri}/versions/#{commit.id}"},
          {'rel' => 'parent', 'href' => "#{resource_uri}?version=#{commit.id}"}
        ] 
      }
    end
    
  end # class ReferenceAPI
end # module API