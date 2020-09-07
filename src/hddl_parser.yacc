/* BISON HDDL grammar file */

/* use modern C++ (14) */
%skeleton "lalr1.cc"

/* use classes */
%define api.token.constructor
%define api.value.type variant

/* needed by modern C++ (14) */
%define api.token.prefix {T_}

%code requires {
    #include <string>

    class HDDLParser;
}

// The parsing context
%param { HDDLParser& hddl_parser }

// enable yy::location location_; used by parser to communicate the file path
%locations

// enable verbose parser output
%define parse.trace
%define parse.error verbose

%code {
    #include <fstream>
    #include <sstream>
    #include "hddl_parser.h"

    Predicate temp_predicate;
}

%token <int>
    NUMBER                  " number "

%token <std::string>
    STRING                  " generic string "
    DOMAIN                  " domain "
    DEFINE                  " define "
    PROBLEM                 " problem "

    HDDL_REQ_KEYWORD        " requirements "
    HDDL_REQ_PARAM          " typing, hola, htn, htn-method-prec "

    HDDL_TYPES_KEYWORD      " types "
    HDDL_PRED_KEYWORD       " predicates "
    HDDL_PARAMS_KEYWORD     " parameters "
    HDDL_OP_PREC_KEYWORD    " precondition "
    HDDL_OP_DUR_KEYWORD     " duration "
    HDDL_OP_EFF_KEYWORD     " effect "
    HDDL_OP_DEC_KEYWORD     " decrease "
    HDDL_TASK_KEYWORD       " task "
    HDDL_METHOD_KEYWORD     " method "

    LPAREN                  " ( "
    COLON                   " : "
    RPAREN                  " ) "
    QM                      " ? "
    HYPHEN                  " - "
    EQUAL                   " = "
    AND                     " and "
    NOT                     " not "

%token
    END  0                  " end_of_file "
    OTHER                   "invalid character"

/* =============================

   Grammar definition starts here
   
================================*/

%%

%start hddl_main_structure;

hddl_main_structure:
    /* (define (domain foo_domain_name) */
    LPAREN DEFINE LPAREN DOMAIN STRING RPAREN { hddl_parser.domain_.domain_name_ = $5; }

    /* (:requirements :typing :durative-actions) */
    requirements

    /* (:types robot location) */
    types

    /* (:predicates pred1 pred2) ; pred1 e.g. (pred_name ?r - robot ?l - location) */
    predicates

    /* (:task deliver :parameters (?p - package ?l - location)) */
    tasks

    /* (:method m-deliver ... */
    methods

    /* final closing parenthesis */
    RPAREN

/* (:requirements req1 req2) */
requirements:
    LPAREN COLON HDDL_REQ_KEYWORD reqs RPAREN

/* allow multiple requirements of the form -> :req1 :req2 */
reqs:
    | reqs req

/* e.g :typing */
req:
    COLON HDDL_REQ_PARAM { hddl_parser.domain_.domain_requirements_.push_back($2); }

/* e.g. (:types kitchen bedroom - location) */
types:
    LPAREN COLON HDDL_TYPES_KEYWORD types_content RPAREN

/* allow multiple instances - types, e.g. kitchen bedroom - location /n kenny youbot - robot */
types_content:
    | types_content instances HYPHEN STRING
    {
        while (hddl_parser.domain_.temp_instances_.size() > 0) {
            hddl_parser.domain_.domain_types_[hddl_parser.domain_.temp_instances_.back()] = $4;
            hddl_parser.domain_.temp_instances_.pop_back();
        }
    }

/* allow multiple strings (instances) e.g. kitchen bedroom */
instances:
    | instances STRING { hddl_parser.domain_.temp_instances_.push_back($2);}

// TODO: add types to some data structure ... type:
//     instances HYPHEN type { hddl_parser.domain_.domain_types_.push_back($2); }

/* (:predicates pred1 pred2) */
predicates:
    LPAREN COLON HDDL_PRED_KEYWORD preds RPAREN

/* allow multiple predicates, e.g. (robot_at ?r - robot ?l - location) */
preds:
    | preds LPAREN STRING predicate_params RPAREN { temp_predicate.name_ = $3; }

/* allow multiple params,   e.g. ?r - robot ?source ?destination - location */
predicate_params:
    | predicate_params keys HYPHEN STRING

/* allow multiple keys, e.g. ?foo ?bar */
keys:
    | keys QM STRING

/* allow multiple tasks e.g. task1 /n task2 /n task3 */
tasks:
    task | tasks task

/* e.g. (:task deliver :parameters (?p - package ?l - location)) */
task:
    LPAREN COLON HDDL_TASK_KEYWORD STRING COLON HDDL_PARAMS_KEYWORD LPAREN task_params RPAREN RPAREN

task_params:
    | task_params keys HYPHEN STRING

methods:
    method | methods method

method:
    LPAREN COLON HDDL_METHOD_KEYWORD COLON HDDL_PARAMS_KEYWORD LPAREN meth_params RPAREN RPAREN

meth_params:
    | meth_params keys HYPHEN STRING

/* :task (deliver ?p ?l2) */

%%

/* =============================

args:
    | STRING { std::cout << "\n\n" << $1 << "\n\n" << std::endl; } args

   Grammar definition ends here

================================*/

void yy::parser::error(const location_type& error_location, const std::string& m)
{
    // show error to the user: 1. type of error , 2. filename , 3. error location (line and column)
    std::cerr << "\n\033[1;31merror: \033[0m" << m << "\nwhile parsing file: " << *error_location.begin.filename << \
    " line : " << error_location.begin.line << ", column : " << error_location.begin.column \
    << ":" << error_location.end.column << "\n" << std::endl;

    // print the file to console and mark where the error is with a "^"
    std::ifstream file(error_location.begin.filename->c_str());
    if (file.is_open())
    {
        std::string line;
        int line_number = 0;
        std::cout << "========  " << *error_location.begin.filename << "  ========" << std::endl;
        // print all lines one by one
        while(std::getline(file, line))
        {
            // print "^" chars to mark where the error is located
            if(error_location.begin.line == line_number++)
            {
                std::stringstream ss_marker;
                // add spaces to string stream marker until error column starts
                for(size_t i = 1; i < error_location.begin.column; i++)
                    ss_marker << " ";

                // add ^ chars from the beginning of the column till end of error
                for(size_t j = error_location.begin.column; j < (error_location.end.column); j++)
                    ss_marker << "^";

                // print line that shows where the error is found
                // std::cout << ss_marker.str() << std::endl;
                std::cout << "\033[1;32m" << ss_marker.str() << "\033[0m" << std::endl;
            }

            // print next line
            std::istringstream ss(line);
            std::cout << ss.str() << std::endl;
        }
        std::cout << "=======================================" << std::endl;
    }
}
