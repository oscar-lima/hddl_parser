#ifndef HDDLPARSER_H
#define HDDLPARSER_H

#include <string>
#include <map>
#include "hddl_parser.tab.hpp" // automatically generated by bison

// Tell Flex the lexer's prototype ...
#define YY_DECL yy::parser::symbol_type yylex (HDDLParser& hddl_parser)
// ... and declare it for the parser's sake.
YY_DECL;

/*********************
 *
 * HDDL domain storing struct
 *
 *********************/

struct Params
{
    std::vector<std::string> params; // args without types
    std::map<std::string, std::string> params_map; // handy arg - type dictionary
};

// e.g. (not (robot_at ?source)), (robot_at ?destination)
struct Predicate
{
    bool negated; // e.g. (-->not (robot_at ?source))
    std::string name; // e.g. (not (-->robot_at ?source))
    Params pred_params; // e.g. (not (robot_at -->?source))
};

struct Task
{
    std::string name;
    Params task_params;
};

struct Method
{
    std::string name;
    Params meth_params;
    Task task;
    bool ordered_subtasks;
    std::vector<Task> subtasks;
};

// stores a full hddl domain model
struct HDDLDomain
{
    // e.g. /home/user/foo_location/bar.hddl
    std::string domain_file_path_;

    std::string domain_name_;
    std::vector<std::string> domain_requirements_;
    std::map<std::string, std::string> domain_types_;
    std::vector<Predicate> domain_predicates_;
    std::vector<Task> domain_tasks_;
    std::vector<Method> domain_meths_;
};

/*********************
 *
 * HDDL domain parser class, receives parsed information
 * from flex (scanner) and bison (grammar parser)
 *
 *********************/

class HDDLParser
{
  public:

  // --------- Constructor

    HDDLParser ();

  // --------- Methods

    // Run the parser on file F.  Return 0 on success.
    int parse(const std::string& f);

    // Handling scanner errors (unmatched tokens)
    void scan_begin();
    void scan_end();

    /* @brief safe access to parsing_ok_ by an external user
     * @return true if hddl parsing succeeded, false otherwise
     */
    bool parsing_ok();

  // --------- Member variables

    HDDLDomain domain_;

    // is set to true by the scanner of no errors occur
    bool parsing_ok_;

    // The token's location used by the scanner.
    yy::location location_;
};

#endif // ! HDDLPARSER_H
