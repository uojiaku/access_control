import Principal "mo:base/Principal";
import Map "mo:map/Map";
import Nat "mo:base/Nat";
import JSON "mo:json/JSON";
import Buffer "mo:base/Buffer";


actor {
  let { phash } = Map;
  stable let counts = Map.new<Principal, Nat>(phash);      // stores a map of principals to counts.  -> This is a stable map which will persist across updates

  public shared ({caller}) func increment() : async Nat {  // increment method                    -> we can increment the count inside of the map
                                                      // shared caller means we can know who is calling the method

    let prev = switch(Map.get(counts, phash, caller)) {  // returns an option out the accounts map
      case (null) { 0 };  
      case (?n) { n };              // if there is a number return the number
    };
    let next = prev + 1;           // find the next value
    Map.set(counts, phash, caller, next);  // update the value
    next;                             // return final value
  };

  public shared query ({caller}) func myCount(): async Nat {   // allows the caller to check what their own count is -> we can check our own count
                                                            // by making it a query function, we can get a faster response back 
                                                                //- we do this if there's no side effects our methods need to have
    return switch (Map.get(counts, phash, caller)) {      // we always do not need to put a return because it will return automatically
      case (null) { 0 };  
      case (?n) { n };
    };
  };

  // we use the json pkg that we imported before to return a json response of a list of all the principals & their counts that are stored in the map

  public query func getCounts() : async Text {      // -> we can get all of the counts as a JSON response
    var entries = Buffer.fromArray<JSON.JSON>([]);  // Json.Json means jsonentry.jsontype
    for ((principal, count) in Map.entries(counts)){  // to insert the entries, were going to iterate through all map entries by destructing the tuple
      entries.add(
        #Object([
          ("principal", #String(Principal.toText(principal))),
          ("count", #String(Nat.toText(count))),
        ])
      );
    }; 
    
    JSON.show(#Array(Buffer.toArray(entries))); // return type will be an array variant Buffer to array

  }
};