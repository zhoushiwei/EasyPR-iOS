//
//  GlobalData.hpp
//  Cartoon
//
//  Created by zhoushiwei on 16/6/7.
//  Copyright © 2016年 zhoushiwei. All rights reserved.
//

#ifndef GlobalData_hpp
#define GlobalData_hpp

#include <stdio.h>
#include <string>
class GlobalData {
public:
    static std::string kDefaultAnnPath;
    static std::string kChineseAnnPath;
    static std::string MainPath;
    
   
    
    
    GlobalData()=default;
public:
    static std::string& DefaultAnnPath() {return kDefaultAnnPath;}
    static std::string& ChineseAnnPath() {return kChineseAnnPath;}
    static std::string& mainBundle() {return MainPath;}
   
    
private:
};
#endif /* GlobalData_hpp */
