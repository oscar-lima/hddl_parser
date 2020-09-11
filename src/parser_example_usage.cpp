#include <iostream>
#include "hddl_parser.h" // defined by user

void print_std_vector(std::string header, std::vector<std::string> &vector_to_print)
{
    // domain requirements
    std::cout << header << ": [";
    for(size_t i = 0; i < vector_to_print.size(); i++)
    {
        std::cout << vector_to_print.at(i);
        // if we are not at the last element we add a separator
        if(i < vector_to_print.size() - 1)
            std::cout << ", ";
    }
    std::cout << "]" << std::endl;
}

int main (int argc, char *argv[])
{
    // create instance of HDDLParser class
    HDDLParser hddl_parser;

    // parse sample file shipped alongside with this code
    hddl_parser.parse("../data/domain.hddl");

    if(hddl_parser.parsing_ok())
    {
        // domain name
        std::cout << "==domain name: [" << hddl_parser.domain_.domain_name_ << "]" << std::endl;

        // use handy function to print std::vector<std::string> in convenient format
        print_std_vector("==domain requirements", hddl_parser.domain_.domain_requirements_);

        std::cout << "==domain types:" << std::endl;
        for(auto it = hddl_parser.domain_.domain_types_.begin(); it!=hddl_parser.domain_.domain_types_.end(); it++) {
            std::cout << it->first << " isOfType " << it->second << std::endl;
        }

        std::cout << "==domain predicates :" << std::endl;
        for(auto it=hddl_parser.domain_.domain_predicates_.begin(); it!=hddl_parser.domain_.domain_predicates_.end(); it++) {
            std::cout << "name : " << it->name << std::endl;

            std::cout << "params :" << std::endl;
            for(auto pit=it->pred_params.begin(); pit!=it->pred_params.end(); pit++) {
                std::cout << "arg : " << pit->first << " type : " << pit->second << std::endl;
            }

            std::cout << "-" << std::endl;
        }
    }
    else
        std::cout << "hddl parsing failed, errors encountered, fix your domain!" << std::endl;

    return 0;
}
