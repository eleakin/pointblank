#' Verify whether numerical column data are
#' less than or equal to a specified value
#' @description Set a verification step where
#' numeric values in a table column should be
#' less than or equal to a specified value.
#' @param agent an agent object of class
#' \code{ptblank_agent}.
#' @param column the column (or a set of columns,
#' provided as a character vector) to which this
#' validation should be applied. Aside from a single
#' column name, column operations can be used to
#' create one or more computed columns (e.g., 
#' \code{a + b} or \code{a + sum(a)}).
#' @param value a numeric value used for this test.
#' Any column values \code{<= value} are considered
#' passing.
#' @param preconditions an optional statement of
#' filtering conditions that may reduce the number
#' of rows for validation for the current
#' validation step. The statements are executed
#' for every row of the table in focus and are
#' often referred as predicate statements (they
#' either return \code{TRUE} or \code{FALSE} for
#' every row evaluated, where rows evaluated as
#' \code{TRUE} are the rows that are retained for
#' the validation step). For example, if a table
#' has columns \code{a}, \code{b}, and \code{c},
#' and, column \code{a} has numerical data, we
#' can write a statement \code{a < 5} that filters
#' all rows in the table where values in column a
#' are less than five.
#' @param brief an optional, text-based description
#' for the validation step.
#' @param warn_count the threshold number for 
#' individual validations returning a \code{FALSE}
#' result before applying the \code{warn} flag.
#' @param notify_count the threshold number for 
#' individual validations returning a \code{FALSE}
#' result before applying the \code{notify} flag.
#' @param warn_fraction the threshold fraction for 
#' individual validations returning a \code{FALSE}
#' over all the entire set of individual validations.
#' Beyond this threshold, the \code{warn} flag will
#' be applied.
#' @param notify_fraction the threshold fraction for 
#' individual validations returning a \code{FALSE}
#' over all the entire set of individual validations.
#' Beyond this threshold, the \code{notify} flag will
#' be applied.
#' @param tbl_name the name of the local or remote
#' table.
#' @param db_type if the table is located in a
#' database, the type of database is required here.
#' Currently, this can be either \code{PostgreSQL}
#' or \code{MySQL}.
#' @param creds_file if a connection to a database
#' is required for reaching the table specified in
#' \code{tbl_name}, then a path to a credentials file
#' can be used to establish that connection. The
#' credentials file is an \code{RDS} containing a
#' character vector with the following items in the
#' specified order: (1) database name (\code{dbname}),
#' (2) the \code{host} name, (3) the \code{port},
#' (4) the username (\code{user}), and (5) the
#' \code{password}. This file can be easily created
#' using the \code{create_creds_file()} function.
#' @param initial_sql when accessing a remote table,
#' this provides an option to provide an initial
#' query component before conducting validations. 
#' An entire SQL statement can be provided here, or,
#' as a shortcut, the initial \code{SELECT...}
#' statement can be omitted for simple queries (e.g.,
#' \code{WHERE a > 1 AND b = 'one'}).
#' @param file_path an optional path for a tabular data
#' file to be loaded for this verification step. Valid
#' types are CSV and TSV files.
#' @param col_types if validating a CSV or TSV file,
#' an optional column specification can be provided
#' here as a string. This string representation is
#' where each character represents one column and the
#' mappings are: \code{c} -> character, \code{i} ->
#' integer, \code{n} -> number, \code{d} -> double, 
#' \code{l} -> logical, \code{D} -> date, \code{T} ->
#' date time, \code{t} -> time, \code{?} -> guess, 
#' or \code{_/-}, which skips the column.
#' @return an agent object.
#' @examples
#' # Create a simple data frame
#' # with a column of numerical
#' # values
#' df <-
#'   data.frame(
#'     a = c(5, 4, 3, 5, 1, 2),
#'     b = c(3, 2, 4, 3, 5, 6))
#' 
#' # Validate that the sum of
#' # values across columns `a`
#' # and `b` are always less
#' # than or equal to 10
#' agent <-
#'   create_agent() %>%
#'   focus_on(tbl_name = "df") %>%
#'   col_vals_lte(
#'     column = a + b,
#'     value = 10) %>%
#'   interrogate()
#' 
#' # Determine if this column
#' # validation has passed by using
#' # `all_passed()`
#' all_passed(agent)
#' #> [1] TRUE
#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows
#' @importFrom rlang enquo UQ
#' @export col_vals_lte

col_vals_lte <- function(agent,
                         column,
                         value,
                         preconditions = NULL,
                         brief = NULL,
                         warn_count = 1,
                         notify_count = NULL,
                         warn_fraction = NULL,
                         notify_fraction = NULL,
                         tbl_name = NULL,
                         db_type = NULL,
                         creds_file = NULL,
                         initial_sql = NULL,
                         file_path = NULL,
                         col_types = NULL) {
  
  column <- rlang::enquo(column)
  column <- (rlang::UQ(column) %>% paste())[2]
  
  preconditions <- rlang::enquo(preconditions)
  preconditions <- (rlang::UQ(preconditions) %>% paste())[2]
  
  if (preconditions == "NULL") {
    preconditions <- NULL
  }
  
  if (is.null(brief)) {
    
    brief <-
      create_autobrief(
        agent = agent,
        assertion_type = "col_vals_gt",
        preconditions = preconditions,
        column = column,
        value = value)
  }
  
  # If "*" is provided for `column`, select all
  # table columns for this verification
  if (column[1] == "all_cols()") {
    column <- get_all_cols(agent = agent)
  }
  
  # Add one or more validation steps
  agent <-
    create_validation_step(
      agent = agent,
      assertion_type = "col_vals_lte",
      column = column,
      value = value,
      preconditions = preconditions,
      brief = brief,
      warn_count = warn_count,
      notify_count = notify_count,
      warn_fraction = warn_fraction,
      notify_fraction = notify_fraction,
      tbl_name = ifelse(is.null(tbl_name), as.character(NA), tbl_name),
      db_type = ifelse(is.null(db_type), as.character(NA), db_type),
      creds_file = ifelse(is.null(creds_file), as.character(NA), creds_file),
      init_sql = ifelse(is.null(initial_sql), as.character(NA), initial_sql),
      file_path = ifelse(is.null(file_path), as.character(NA), file_path),
      col_types = ifelse(is.null(col_types), as.character(NA), col_types))
  
  # If no `brief` provided, set as NA
  if (is.null(brief)) {
    brief <- as.character(NA)
  }
  
  # Place the validation step in the logical plan
  agent$logical_plan <-
    dplyr::bind_rows(
      agent$logical_plan,
      tibble::tibble(
        component_name = "col_vals_lte",
        parameters = as.character(NA),
        brief = brief))
  
  agent
}
