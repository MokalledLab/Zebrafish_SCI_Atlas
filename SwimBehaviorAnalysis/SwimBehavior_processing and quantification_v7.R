##HOUSE KEEPING##

#Clear all variables to start from scratch
rm(list = ls())

# IMPORTANT!!!!! If DEBUG is TRUE then you will not be able to get user input,
# and groups will always unblind to A=Het, B=Mut, C=WT.
DEBUG <- FALSE

library(tcltk)
setwd(tclvalue(tkchooseDirectory()))

options(warn = 0)

#Load appropriate libraries
library(svDialogs)
library(MASS)
library(RColorBrewer)
library(dplyr)
library(ggplot2)
library(tidyr)
library(stringi)
library(combinat)
library(data.table)
library(scales)
library(RcppHungarian)

############ Directories ############

#Create directories for the results
RESULTS_DIR <- paste0(getwd(), "/Results_v7/")
GRAPHS_DIR <- paste0(RESULTS_DIR, "Graphs/")
INDIVIDUALS_DIR <- paste0(GRAPHS_DIR, "Individuals/")
GROUPS_DIR <- paste0(GRAPHS_DIR, "Groups/")
DIAGNOSTICS_DIR <- paste0(RESULTS_DIR, "Diagnostics/")
dir.create(RESULTS_DIR, showWarnings = FALSE)
dir.create(GRAPHS_DIR, showWarnings = FALSE)
dir.create(INDIVIDUALS_DIR, showWarnings = FALSE)
dir.create(GROUPS_DIR, showWarnings = FALSE)
dir.create(DIAGNOSTICS_DIR, showWarnings = FALSE)

############ Column Conversion Constants ############

# LTS_MAP is a long to short colname map (named list)
# NOTE: the LTS_MAP below is a helpful tool
#    for converting column names between 
#    long, human-readable names and short,
#    code-ready column names. I wrote it in this way
#    to avoid hard-coding the location of any given column.
#    The "Activity [%]" column could be column number 7 or column number 142.
#    It doesn't matter, as long as the LTS_MAP is up-to-date and the long column names
#    are the same for summary_avg and summary_full
LTS_MAP <- list(
  "Timepoint" = "Timepoint",
  "Group" = "Group",
  "Fish" = "Fish",
  "Flowspeed" = "Flowspeed",
  "Avg_YPosition [px]" = "Y",
  "Distance [px]" =  "D",
  "Activity [%]" = "A",
  "Flow-Adjusted Activity [%]" = "AFA",
  "Efficiency" = "E",
  "Swimming Against Flow [%]" = "Dr",
  "Flow-Adjusted Swimming Against Flow [%]" = "DrFAE",
  "Burst Duration [frames]" = "L",
  "Burst Frequency [bursts/min]" = "F",
  "Burst Amplitude [pixels]" = "Amp",
  "Time in Y-Quadrant 1 [%]" = "TY1Q",
  "Time in Y-Quadrant 2 [%]" = "TY2Q",
  "Time in Y-Quadrant 3 [%]" = "TY3Q",
  "Time in Y-Quadrant 4 [%]" = "TY4Q"
)

LongColnamesToShortColnames <- function(prev_colnames) {
  new_colnames <- c()
  for (n in prev_colnames) {
    if (!is.null(LTS_MAP[[n]])) {
      new_colnames <- append(new_colnames, LTS_MAP[[n]])
    } else {
      new_colnames <- append(new_colnames, n)
    }
  }
  return(new_colnames)
}


############ Swim Metric Constants ############

# CHANGE THIS TO ADJUST STRINGENCY OF FILTER.
# A VALUE OF 50 MEANS THAT ANY FISH WHICH IS ACTIVE
# FOR LESS THAN 50% OF 10 CM/S SWIM IS EXCLUDED FROM THE ANALYSIS
ACTIVITY_FILTER <- 40

# Frame numbers for flow rates
FLOW_0 <- 1
FLOW_0_ENDS <- 6000
FLOW_10 <- 6001
FLOW_10_ENDS <- 12000
FLOW_20 <- 12001
FINAL_FRAME <- 18001

# Change this value to adjust what is considered active (units are in pixels)
PIXEL_ACTIVITY_THRESHOLD <- 5

############ Constants for Naive Direction Estimation ############
STATIC_CHANGE_THRESHOLD <- 5

############ Constants for Flow Adjusted Direction Estimation ############

# Length of the tunnel quadrants (assume tunnel is 2000 pixels tall)
TUNNEL_LENGTH <- 2000 # px
QUADRANT_LENGTH <- 500 # px

# Frames per second
FPS <- 20

# Pixels per centimeter
PX_PER_CM <- TUNNEL_LENGTH / 28

# Frame window size for y-moving-mean method to estimate direction
MOVING_MEAN_WIDTH <- 3

FLOW_RATES <- c(0, 10, 20) # cm per s

# If the fish is behind here and not moving forward,
#    it's considered exhausted and does not count as
#    swimming against the flow.
EXHAUSTION_BOUNDARY <- 3 * PX_PER_CM # 3 cm, in pixels.

############ Helpers ############

DEFAULT_THEME <- theme(
  panel.grid = element_blank(),
  axis.text = element_text(size = 14),
  axis.title = element_text(size = 20, face = "bold"),
  strip.text.y = element_text(size = 14),
  legend.text = element_text(size = 14),
  legend.title = element_text(size = 14)
)

DEFAULT_THEME_BLANK_X_TEXT <- theme(
  panel.grid = element_blank(),
  axis.text = element_text(size = 14),
  axis.title = element_text(size = 20, face = "bold"),
  axis.text.x = element_blank(),
  strip.text.y = element_text(size = 14),
  legend.text = element_text(size = 14),
  legend.title = element_text(size = 14)
)

Outersect <- function(x, y) {
  sort(
    c(setdiff(x, y),
      setdiff(y, x)
    )
  )
}

# Returns the first element in a "_" delimited string.
# Assumes the filename is WPI_GROUP_TEAMNUMBER_{the rest here}
#   where WPI_GROUP_TEAMNUMBER_ is unique to this file.
FilenameToTimepoint <- function(filename) {
  return(unlist(strsplit(filename, "_"))[1])
}

# Returns the second element in a "_" delimited string.
# Assumes the filename is WPI_GROUP_TEAMNUMBER_{the rest here}
#   where WPI_GROUP_TEAMNUMBER_ is unique to this file.
FilenameToGroup <- function(filename) {
  return(unlist(strsplit(filename, "_"))[2])
}

# Returns the first three elements in a "_" delimited string.
#   Optionally includes "_" at the end (TRUE by default).
# Assumes the filename is WPI_GROUP_TEAMNUMBER_{the rest here}
#   where WPI_GROUP_TEAMNUMBER_ is unique to this file.
FilenameToUniqueTag <- function(filename, with_final_underscore = TRUE) {
  rv <- paste(unlist(strsplit(filename, "_"))[1:3], collapse = "_")
  if (with_final_underscore) {
    rv <- paste0(rv, "_")
  }
  return(rv)
}

FilenameToFishTag <- function(filename, fishID) {
  return(paste(c(unlist(strsplit(filename, "_"))[1:2], fishID), collapse = "_"))
}

FilenameWithoutFinalUnit <- function(filename) {
  contents <- unlist(strsplit(filename, "_"))
  return(
      paste(contents[seq_len(length(contents) - 1)], collapse = "_")
  )
}

# Determine the number of starting objects as the number of objects
#     in the first frame or the average (nearest interger)
#     number of objects in the first 1000 frames...whichever is higher.
CountObjectsPreAlignment <- function(raw) {
  return(max(
    sum(raw$Frame == 1),
    round(sum(raw$Frame <= 1000) / 1000)
  ))
}

ReadRawCSV <- function(raw_filename) {
  raw <- read.csv(raw_filename, header = TRUE, row.names = 1)
  colnames(raw) <- c("Frame", "Area", "X", "Y")
  raw$Frame <- as.integer(raw$Frame)
  return(raw)
}

############ Setup ############

AskBoolean <- function(question, debugging_default) {
  if (DEBUG) {
    return(debugging_default)
  }
  return(askYesNo(
    question,
    default = TRUE,
    prompts = getOption("askYesNo", gettext(c("Yes", "No", "Cancel")))))
}

PromptToCombineData <- function(groups) {
  # Gather as many combinations as the user prefers.
  combos <- c()
  combine <- AskBoolean(
    paste0("Available groups:\n", stri_flatten(groups, collapse = " "),
      "\nWould you like to combine any groups?"), FALSE)
  while (combine) {
    combo <- dlg_input(
      message = paste0(
        "Available groups:\n", stri_flatten(groups, collapse = " "),
        "\n\n Which groups would you like to combine?\n(enter exact name seperated by commas)"),
      default = "", gui = .GUI
    )$res
    combo <- unlist(strsplit(combo, ","))
    combos <- append(combos, list(combo))
    combine <- AskBoolean("Would you like to combine any other groups?", FALSE)
  }
  return(combos)
}

PromptToUnblind <- function(raw_files, aligned_files) {
  do_unblind <- AskBoolean("Would you like to unblind the groups?", FALSE)
  #Unblind the groups (if desired)
  groups <- unique(c(unlist(lapply(raw_files, FilenameToGroup)), unlist(lapply(aligned_files, FilenameToGroup))))
  groups_blind <- groups
  groups_unblind <- groups
  if (do_unblind) {
    for (i in seq_len(length(groups_blind))) {
      new_name <- dlg_input(
        message = paste0("Enter the unblinded name for group ", groups_blind[i], ":"),
        default = "", gui = .GUI)$res
      if (nchar(new_name) > 0) {
        groups_unblind[i] <- new_name
      }
    }
    groups <- unique(groups_unblind)
  }
  else {
    groups <- unique(groups)
  }
  if (DEBUG) {
    groups <- c("Het", "Mut", "WT")
    do_unblind <- TRUE
  }
  return(list("groups" = groups, "groups_blind" = groups_blind, "is_unblinded" = do_unblind))
}

ConfirmNumberOfObjects <- function(raw_files, file_patterns_to_align) {
  object_counts <- c()
  message("Identifying the number of objects in each movie...\r")
  message("Objects per movie:\n")
  for (file_pattern in file_patterns_to_align) {
    raw_filename <- paste0(file_pattern, "_raw.csv")
    message(paste0(file_pattern, " - ", CountObjectsPreAlignment(ReadRawCSV(raw_filename)), "\n"))
  }
  match <- AskBoolean("Do the numbers match the actual number of fish in each movie?", TRUE)
  if (!match) {
    msg_box(message = paste0("Use ImageJ to re-track the movies with extra objects. ",
      "Adjust the ROI and threshold so that no extra objects are captured. ",
      "Repeat this alignment with the new raw tracking files."))
    stop("Correct tracking and then repeat data analysis.")
  }
}

# All user input is contained here.
Setup <- function() {
  #Get a list of raw tracking files which need to be aligned
  raw_files <- as.list(list.files(path = getwd(), pattern = "_raw.csv"))
  aligned_files <- as.list(list.files(path = getwd(), pattern = "_aligned.csv"))
  if (length(raw_files) > length(aligned_files)) {
    file_patterns_to_align <- Outersect(
      unlist(lapply(raw_files, FilenameWithoutFinalUnit)),
      unlist(lapply(aligned_files, FilenameWithoutFinalUnit)))
  } else {
    file_patterns_to_align <- c()
  }

  #Pre-alignment Quality Control (check that the number of
  #    objects to be tracked matches the number of fish in each movie)
  if (length(file_patterns_to_align) > 0 && !DEBUG) {
    ConfirmNumberOfObjects(raw_files, file_patterns_to_align)
  }

  #Choose whether to filter out fish with asymmetric fish poses
  do_filter <- AskBoolean("Would you like to remove non-swimming fish from the analysis?", FALSE)

  unblind_result <- PromptToUnblind(raw_files, aligned_files)

  combos <- PromptToCombineData(unblind_result$groups)

  return(list(
    "file_patterns_to_align" = file_patterns_to_align,
    "groups" = unblind_result$groups,
    "groups_blind" = unblind_result$groups_blind,
    "is_unblinded" = unblind_result$is_unblinded,
    "do_filter" = do_filter,
    "combos" = combos
  ))
}

############ Aligning Raw Data ############

FilterSingleFrameDirections <- function(directions) {
  for (j in 2:(length(directions) - 1)) {
    if (directions[j] == directions[j - 1] || directions[j] == directions[j + 1]) {
      next
    }
    directions[j] <- directions[j + 1]
  }
  return(directions)
}

GetAlignedColumnNames <- function(nfish) {
  cnames <- c()
  for (i in seq_len(nfish)) {
    cnames <- c(cnames, c(
      paste0("X", i),
      paste0("Y", i),
      paste0("Distance", i),
      paste0("Active", i),
      paste0("Direction", i)))
  }
  return(cnames)
}

# Returns a DataFrame for the aligned file
OrderedXYToAligned <- function(orderedXY) {
  nfish <- dim(orderedXY)[1]
  nframes <- dim(orderedXY)[2]
  aligned <- data.frame(matrix(nrow = nframes, ncol = 5 * nfish), row.names = seq_len(nframes))
  colnames(aligned) <- GetAlignedColumnNames(nfish)
  Xcols <- seq(1, ncol(aligned), 5)
  Ycols <- seq(2, ncol(aligned), 5)
  for (i in seq_len(nfish)) {
    # Fill in X values
    aligned[, Xcols[i]] <- orderedXY[i, , 1]
    # Fill in Y values
    aligned[, Ycols[i]] <- orderedXY[i, , 2]
    distance_col <- Ycols[i] + 1
    # Calculate distances
    aligned[1, distance_col] <- 0
    aligned[2:nframes, distance_col] <- sqrt(
      abs(aligned[, Xcols[i]][2:nframes] - aligned[, Xcols[i]][seq_len(nframes - 1)])^2 +
      abs(aligned[, Ycols[i]][2:nframes] - aligned[, Ycols[i]][seq_len(nframes - 1)])^2
    )
    # Calculate activity
    active_col <- Ycols[i] + 2
    aligned[, active_col] <- aligned[, distance_col] > PIXEL_ACTIVITY_THRESHOLD
    yChange <- aligned[2:nframes, Ycols[i]] - aligned[seq_len(nframes - 1), Ycols[i]]
    yChange <- c(yChange[1], yChange)
    direction_col <- Ycols[i] + 3
    aligned[, direction_col] <- rep_len("Static", nframes) 
    aligned[, direction_col][yChange > STATIC_CHANGE_THRESHOLD] <- "Against"
    aligned[, direction_col][yChange < -STATIC_CHANGE_THRESHOLD] <- "With"
    aligned[, direction_col] <- FilterSingleFrameDirections(aligned[, direction_col])
  }
  return(aligned)
}

# Returns a matrix of distances:
#   Each row is a currentVals point
#   Each column is a priorVals point
GetDistanceMatrix <- function(priorVals, currentVals) {
  GetNorm <- function(x) sqrt(sum(x^2))
  nrows <- max(1, nrow(currentVals))
  distances <- matrix(nrow = nrows, ncol = nrow(priorVals))
  for (i in seq_len(nrows)) {
    distances[i, ] <- apply(t(priorVals) - currentVals[i, ], 2, GetNorm)
  }
  return(distances)
}

# Returns a list of pairs:
#   index to currentVals -> index into newVals
GetOptimalMapping <- function(priorVals, currentVals) {
  # The Hungarian Algorithm (https://brilliant.org/wiki/hungarian-matching/)
  distMatrix <- GetDistanceMatrix(priorVals, currentVals)
  bestPairs <- NULL
  if (is.null(nrow(distMatrix))) {
    bestPairs <- matrix(c(1, order(distMatrix)[1]), nrow = 1, ncol = 2)
  } else {
    bestPairs <- RcppHungarian::HungarianSolver(distMatrix)$pairs
  }
  return(bestPairs)
}

# Sorts points in currentVals to minimize the distance
# between priorVals and currentVals.
GetNextOrderedRow <- function(priorVals, currentVals) {
  if (is.null(nrow(priorVals))) {
    return(unlist(currentVals))
  }
  bestPairs <- GetOptimalMapping(priorVals, currentVals)
  # Copy this frame's points into the matrix
  newVals <- array(NA, dim = dim(priorVals))
  # Special case since R is stupid and doesn't allow 1-D matrices.
  # We should really use python for this kind of thing.
  if (is.null(dim(currentVals)) || nrow(currentVals) == 1) {
    newVals[bestPairs[2], ] <- currentVals
  } else {
    for (i in seq_len(nrow(bestPairs))) {
      newVals[bestPairs[i, 2], ] <- currentVals[bestPairs[i, 1], ]
    }
  }
  # If any NaN exist, copy stuff over.
  # First, copy the X values.
  newVals[, 1][is.na(newVals[, 1])] <- priorVals[, 1][is.na(newVals[, 1])]
  # Now, copy the Y values.
  newVals[, 2][is.na(newVals[, 2])] <- priorVals[, 2][is.na(newVals[, 2])]
  return(newVals)
}

# Returns a list containing an array of shape (nfish, nframes, 2) and some diagnostic values
# The array has x,y coordinates for every fish in every frame.
RawToOrderedXYMatrix <- function(raw) {
  DataFrameToArray <- function(df) array(unlist(df), dim = dim(df))
  nframesMissingObjects <- 0
  nframesExtraObjects <- 0
  nfish <- CountObjectsPreAlignment(raw)
  nfishInFrame <- nfish
  raw[raw$Frame == 1, ]$X
  raw[raw$Frame == 1, ]$Y
  result <- array(data = NA, dim = c(nfish, FINAL_FRAME, 2))
  # Prepopulate the first frame
  init_vals <- unlist(raw[raw$Frame == 1, c("X", "Y")])
  if (nfish > 1) {
    init_vals <- array(init_vals, dim(result[, 1, ]))
  }
  result[, 1, ] <- init_vals
  # From the second frame onward,
  # match the new point to the closest previous point.
  for (i in 2:FINAL_FRAME) {
    if (i %in% raw$Frame) {
      valsToAdd <- DataFrameToArray(raw[raw$Frame == i, c("X", "Y")])
      nfishInFrame <- dim(valsToAdd)[1]
      if (nfishInFrame <= nfish) {
        result[, i, ] <- GetNextOrderedRow(
          result[, i - 1, ],
          valsToAdd
        )
      }
    }
    if (nfishInFrame < nfish) {
      nframesMissingObjects <- nframesMissingObjects + 1 
    }
    if (nfishInFrame > nfish) {
      nframesExtraObjects <- nframesExtraObjects + 1
    }
    # If any NaN exist, copy stuff over.
    result[, i, ][is.na(result[, i, ])] <- result[, i - 1, ]
  }
  return(list(
    "orderedXY" = result,
    "nframes" = length(unique(raw$Frame)),
    "nfish" = nfish,
    "nframesMissingObjects" = nframesMissingObjects,
    "nframesExtraObjects" = nframesExtraObjects))
}

# Creates *_aligned.csv
# Creates Diagnostics.csv
AlignData <- function(file_patterns_to_align, groups) {
  if (length(file_patterns_to_align) == 0) {
    print("Files have already been aligned, so there will be no diagnostics output.")
    return(NULL)
  }
  diagnostics_filename <- paste0(DIAGNOSTICS_DIR, "Diagnostics.csv")
  full_diagnostics <- data.frame()
  if (file.exists(diagnostics_filename)) {
    full_diagnostics <- read.csv(paste0(DIAGNOSTICS_DIR, "Diagnostics.csv"), row.names = 1)
  }
  raw_files <- as.list(list.files(path = getwd(), pattern = "_raw.csv"))
  counter <- 1
  for (file_pattern in file_patterns_to_align) {
    message("Aligning file ", counter, " of ", length(file_patterns_to_align), "\r",
      appendLF = (counter == length(file_patterns_to_align)))
    counter <- counter + 1
    raw_filename <- paste0(file_pattern, "_raw.csv")
    raw <- ReadRawCSV(raw_filename)
    ordering_result <- RawToOrderedXYMatrix(raw)
    if (ordering_result$nframesExtraObjects > 0) {
      warning(ordering_result$nframesExtraObjects,
            " frames in ", raw_filename, " contained extra objects. These frames were excluded from the analysis.")
    }
    diagnostics <- c(
      raw_filename,
      ordering_result$nframes,
      ordering_result$nfish,
      ordering_result$nframesMissingObjects,
      ordering_result$nframesExtraObjects)
    aligned <- OrderedXYToAligned(ordering_result$orderedXY)
    aligned_filename <- paste0(file_pattern, "_aligned.csv")
    write.csv(aligned, file = aligned_filename)
    distance_cols <- seq(1, ncol(aligned), 5)
    for (fishi in seq_len(length(distance_cols))) {
      # add Frames with >240 px jumps to diagnostics
      diagnostics <- c(diagnostics,
        paste(which(
          aligned[2:FINAL_FRAME, distance_cols[fishi]] -
            aligned[seq_len(FINAL_FRAME - 1), distance_cols[fishi]] > 240),
          collapse = "|"))
    }
    full_diagnostics <- rbind(full_diagnostics, diagnostics)
  }
  colnames(full_diagnostics)[seq_len(5)] <- c(
    "File", "# of Frames", "# of starting objects",
    "# of Frames with missing/merged objects", "# of Frames with extra objects")
  colnames(full_diagnostics)[6:length(full_diagnostics)] <- "Frames with >240 px jumps"
  row.names(full_diagnostics) <- seq_len(nrow(full_diagnostics))
  write.csv(full_diagnostics, file = diagnostics_filename)
}

############ Assembling Data Frames ############

# Takes frame numbers and Y values and decides
# which direction the fish is swimming:
# Against, With, or Static
CalculateDirectionsWithFlow <- function(Y, flow_rate) {
  max_exp_drift <- flow_rate * PX_PER_CM / FPS # units: px per frame
  # The denominator below was chosen using detect_direction_with_flow.py
  high_against_limit <- -1 * max_exp_drift / 12 # slowest you can swim forward
  low_with_limit <- -1 * max_exp_drift # Fastest you can drift backward
  # TODO (LATER) write a more efficient solution.
  MM <- function(i) {
    # Full R frame window begins to slide late, stops sliding early
    i_start <- max(1, i - floor(MOVING_MEAN_WIDTH / 2))
    i_end <- min(i + floor(MOVING_MEAN_WIDTH / 2), length(Y))
    return(mean(Y[i_start:i_end]))
  }
  yMM <- unlist(purrr::map(seq_len(length(Y)), MM))
  y_change <- c(Y[2:length(Y)] - Y[seq_len(length(Y) - 1)], 0)
  yMM_change <- c(yMM[2:length(yMM)] - yMM[seq_len(length(yMM) - 1)], 0)
  labels <- rep("Static", length(yMM_change))
  labels[yMM_change > high_against_limit] <- "Against"
  labels[yMM_change < low_with_limit] <- "With"
  # Assume the fish is exhausted if it is in the region and not moving forward.
  labels[y_change < STATIC_CHANGE_THRESHOLD & yMM <= EXHAUSTION_BOUNDARY] <- "Static"
  labels <- FilterSingleFrameDirections(labels)
  return(labels)
}

# Takes run-length-encoding of directions and finds the mean distance swum against flow per burst
# NOTE: the v6 code had a bug that failed to calculate the correct summed distance
#       when the first frame was part of an "Against" series.
#       Basically, if the first 24 frames were "Against", instead of summing distances
#       from 1:24, he would try to sum distances from 25:24. A great bug, indeed.
CalculateMeanAmplitudes <- function(aligned_data, distance_column, direction_column, direction_rle) {
  distances <- aligned_data[, distance_column]
  directions <- aligned_data[, direction_column]
  where_against <- which(direction_rle$values == "Against" & direction_rle$length > 1)
  rle_frame_mappings <- c(1, cumsum(direction_rle$lengths) + 1)
  if (length(where_against) == 0) {
    return(0)
  }
  # List of index for the first "Against" frame in a series
  starts <- rle_frame_mappings[where_against]
  # List of index for the last "Against" frame in a series
  ends <- rle_frame_mappings[where_against] + direction_rle$lengths[where_against] - 1
  running_sum <- 0
  for (i in seq_len(length(starts))) {
    running_sum <- running_sum + sum(distances[starts[i]:ends[i]])
  }
  return(running_sum / length(starts))
}

# If the fish does not burst, still returns 0 (not NA).
CalculateMeanBurstDuration <- function(direction_rle) {
  burst_durations <- direction_rle$lengths[
    direction_rle$values == "Against" & direction_rle$length > 1]
  if (length(burst_durations) == 0) {
    return(0)
  }
  return(mean(burst_durations))
}

Unblind <- function(data_frame, groups_unblind, groups_blind, is_unblinded) {
  #Convert group names to unblinded names...
  if (is_unblinded) {
    for (i in seq_len(length(groups_blind))) {
      data_frame[data_frame$Group == groups_blind[i], ]$Group <- groups_unblind[i]
    }
  }
  return(data_frame)
}

AssembleBulkData <- function(XFinal, YFinal) {
  message("Assembling bulk data...", "\r")
  ID <- as.data.frame(colnames(YFinal))
  timepoint <- as.data.frame(unlist(lapply(colnames(YFinal), FilenameToTimepoint)))
  group <- as.data.frame(unlist(lapply(colnames(YFinal), FilenameToGroup)))
  tmp <- cbind(timepoint, group, ID)
  colnames(tmp) <- c("Timepoint", "Group", "ID")
  tmp <- data.frame(t(tmp))
  colnames(tmp) <- as.character(colnames(YFinal[1, ]))
  YFinal2 <- as.data.frame(lapply(YFinal, factor))
  colnames(YFinal2) <- as.character(colnames(YFinal[1, ]))
  YFinal2 <- as.data.frame(t(rbind(tmp, YFinal2)))
  YFinal2 <- suppressWarnings(tidyr::gather(YFinal2, Frame, Y, 4:ncol(YFinal2)))
  XFinal2 <- as.data.frame(lapply(XFinal, factor))
  colnames(XFinal2) <- as.character(colnames(YFinal[1, ]))
  XFinal2 <- as.data.frame(t(rbind(tmp, XFinal2)))
  XFinal2 <- suppressWarnings(tidyr::gather(XFinal2, Frame, X, 4:ncol(XFinal2)))
  bulk_full <- cbind(YFinal2, XFinal2["X"])
  #Add extra column for flowspeed
  bulk_full <- cbind(bulk_full, Flowspeed = NA)
  bulk_full[as.integer(bulk_full$Frame) < FLOW_10, "Flowspeed"] <- "0 cps"
  bulk_full[as.integer(bulk_full$Frame) < FLOW_20 & as.integer(bulk_full$Frame) >= FLOW_10, "Flowspeed"] <- "10 cps"
  bulk_full[as.integer(bulk_full$Frame) >= FLOW_20, "Flowspeed"] <- "20 cps"
  bulk_full$Group <- as.character(bulk_full$Group)
  bulk_full$Flowspeed <- as.character(bulk_full$Flowspeed)
  return(bulk_full)
}

# Note that Quadrant 1 is from y = 0 to y = QUADRANT_LENGTH and so on.
#     and lower numbers are further from the source of the flow.
# Flow originates from the end of quadrant 4.
CalculateTimeInQuadrant <- function(y_values, quadrant_number) {
  quadrant_starts <- QUADRANT_LENGTH * (quadrant_number - 1)
  quadrant_ends <- QUADRANT_LENGTH * quadrant_number
  total_in_quadrant <- sum(y_values >= quadrant_starts & y_values <= quadrant_ends)
  if (quadrant_number == 4) {
    total_in_quadrant <- sum(y_values >= quadrant_starts)
  }
  return(total_in_quadrant * 100 / length(y_values))
}

# Creates a row of descriptive statistcs
CreateSwimMetricSummaryRow <- function(
    aligned_data, timepoint, groupID, fishID,
    y_column, distance_column, activity_column, direction_column) {
  direction <- as.data.frame(aligned_data[, direction_column])
  direction[, 1] <- as.character(direction[, 1])
  part1 <- FLOW_0:FLOW_0_ENDS
  part2 <- FLOW_10:FLOW_10_ENDS
  part3 <- FLOW_20:FINAL_FRAME

  T0 <- rle(direction[part1, 1])
  T10 <- rle(direction[part2, 1])
  T20 <- rle(direction[part3, 1])

  directions10 <- CalculateDirectionsWithFlow(aligned_data[part2, y_column], FLOW_RATES[2])
  directions20 <- CalculateDirectionsWithFlow(aligned_data[part3, y_column], FLOW_RATES[3])

  summary_row <- data.frame(
    Timepoint = timepoint,
    Group = groupID,
    Fish = fishID,
    #Distance Swam
    D0  = sum(aligned_data[part1, distance_column]),
    D10 = sum(aligned_data[part2, distance_column]),
    D20 = sum(aligned_data[part3, distance_column]),
    #Activity
    A0  = sum(aligned_data[part1, activity_column]) * 100 / length(part1),
    A10 = sum(aligned_data[part2, activity_column]) * 100 / length(part2),
    A20 = sum(aligned_data[part3, activity_column]) * 100 / length(part3),
    # Flow Adjusted Activity
    AFA0  = sum(aligned_data[part1, activity_column]) * 100 / length(part1),
    AFA10 = sum(directions10 != "Static") * 100 / length(part2),
    AFA20 = sum(directions20 != "Static") * 100 / length(part3),
    #Efficiency
    E0  = mean(aligned_data[part1, y_column])^2 / sum(aligned_data[part1, distance_column]),
    E10 = mean(aligned_data[part2, y_column])^2 / sum(aligned_data[part2, distance_column]),
    E20 = mean(aligned_data[part3, y_column])^2 / sum(aligned_data[part3, distance_column]),
    # Flow-independent measurement of time spent swimming against flow
    Dr0  = sum(direction[part1, ] == "Against") * 100 / length(part1),
    Dr10 = sum(direction[part2, ] == "Against") * 100 / length(part2),
    Dr20 = sum(direction[part3, ] == "Against") * 100 / length(part3),
    # Flow-adjusted estimate for time spent swimming against flow
    DrFAE0 = NA, # Must have all three, otherwise stuff breaks. This script is disastrously fragile.
    DrFAE10 = sum(directions10 == "Against") * 100 / length(part2),
    DrFAE20 = sum(directions20 == "Against") * 100 / length(part3),
    #Burst Duration
    L0  = CalculateMeanBurstDuration(T0),
    L10 = CalculateMeanBurstDuration(T10),
    L20 = CalculateMeanBurstDuration(T20),
    #Burst Frequency (bursts / min)
    F0  = sum(T0$values == "Against" & T0$length > 1) / (length(part1) / (FPS * 60)),
    F10 = sum(T10$values == "Against" & T10$length > 1) / (length(part2) / (FPS * 60)),
    F20 = sum(T20$values == "Against" & T20$length > 1) / (length(part3) / (FPS * 60)),
    #Mean Burst Amplitude
    Amp0  = CalculateMeanAmplitudes(aligned_data[part1, ], distance_column, direction_column, T0),
    Amp10 = CalculateMeanAmplitudes(aligned_data[part2, ], distance_column, direction_column, T10),
    Amp20 = CalculateMeanAmplitudes(aligned_data[part3, ], distance_column, direction_column, T20),
    # Time in Y Quadrants
    TY1Q0  = CalculateTimeInQuadrant(aligned_data[part1, y_column], 1),
    TY1Q10 = CalculateTimeInQuadrant(aligned_data[part2, y_column], 1),
    TY1Q20 = CalculateTimeInQuadrant(aligned_data[part3, y_column], 1),
    TY2Q0  = CalculateTimeInQuadrant(aligned_data[part1, y_column], 2),
    TY2Q10 = CalculateTimeInQuadrant(aligned_data[part2, y_column], 2),
    TY2Q20 = CalculateTimeInQuadrant(aligned_data[part3, y_column], 2),
    TY3Q0  = CalculateTimeInQuadrant(aligned_data[part1, y_column], 3),
    TY3Q10 = CalculateTimeInQuadrant(aligned_data[part2, y_column], 3),
    TY3Q20 = CalculateTimeInQuadrant(aligned_data[part3, y_column], 3),
    TY4Q0  = CalculateTimeInQuadrant(aligned_data[part1, y_column], 4),
    TY4Q10 = CalculateTimeInQuadrant(aligned_data[part2, y_column], 4),
    TY4Q20 = CalculateTimeInQuadrant(aligned_data[part3, y_column], 4)
  )
  return(summary_row)
}

# Returns a list containing "is_active" and "filtered"
CheckActivity <- function(filename, aligned_data, activity_column, filtered) {
  percent_activity <- sum(
    aligned_data[FLOW_10:FLOW_10_ENDS, activity_column]) * 100 / (FLOW_10_ENDS - FLOW_10 + 1)
  activity_string <- "Pass"
  is_active <- TRUE
  if (percent_activity < ACTIVITY_FILTER) {
    activity_string <- "Fail"
    is_active <- FALSE
  }
  filtered_row <- c(FilenameToUniqueTag(filename, with_final_underscore = FALSE),
      percent_activity,
      activity_string)
  return(list("filtered_row" = filtered_row, "is_active" = is_active))
}

GetXY <- function(
  XFinal, YFinal, aligned_data, final_summary,
  filtered, count, groupID, filename, do_filter) {
  timepoint <- FilenameToTimepoint(filename)
  headings <- colnames(aligned_data)
  #Extract column names from the file
  ycol <- grep(pattern = "Y", headings, value = T)
  xcol <- grep(pattern = "X", headings, value = T)
  dcol <- grep(pattern = "Distance", headings, value = T)
  acol <- grep(pattern = "Active", headings, value = T)
  drcol <- grep(pattern = "Direction", headings, value = T)
  #Assemble data
  for (j in seq_len(length(ycol))) {
    count <- count + 1
    fishID <- count

    #Remove non-swimmers...
    activity_result <- CheckActivity(filename, aligned_data, acol[j], filtered)
    filtered[nrow(filtered) + 1, ] <- activity_result$filtered_row
    if (do_filter && !activity_result$is_active) next

    summary_row <- CreateSwimMetricSummaryRow(
      aligned_data, timepoint, groupID, fishID,
      ycol[j], dcol[j], acol[j], drcol[j])
    
    #Extract data and prep columns for calculating directional metrics
    YFinal <- cbind(YFinal, dplyr::select(aligned_data, ycol[j]))
    XFinal <- cbind(XFinal, dplyr::select(aligned_data, xcol[j]))
    aligned_data[, dcol[j]] <- as.numeric(aligned_data[, dcol[j]])
    
    if (is.null(final_summary)) {
      final_summary <- data.frame(matrix(nrow = 0, ncol = ncol(summary_row)))
      colnames(final_summary) <- colnames(summary_row)
    }
    final_summary[nrow(final_summary) + 1, ] <- summary_row
    colnames(YFinal)[ncol(YFinal)] <- FilenameToFishTag(filename, fishID)
    colnames(XFinal)[ncol(XFinal)] <- FilenameToFishTag(filename, fishID)
  }
  return(list(
    "X" = XFinal, "Y" = YFinal, "final_summary" = final_summary,
    "count" = count, "filtered" = filtered))
}

# Creates Activity_Filter.csv
# Creates BulkData_Full.csv
# Indirectly creates SummaryData_Full
CalculateSwimMetrics <- function(groups, groups_blind, is_unblinded, do_filter) {
  ##COMPILE DATA AND CALCULATE SWIM METRICS##
  #Combine the data from each file
  aligned_files <- list.files(pattern = "_aligned.csv")
  filtered <- data.frame(matrix(nrow = 0, ncol = 3))
  colnames(filtered) <- c("Fish", "Activity [%]", "Pass/Fail")
  YFinal <- data.frame(matrix(nrow = FINAL_FRAME, ncol = 0))
  XFinal <- data.frame(matrix(nrow = FINAL_FRAME, ncol = 0))
  final_summary <- NULL
  old_groupID <- NULL
  count <- 0
  for (i in seq_len(length(aligned_files))) {
    filename <- aligned_files[i]
    message("Combining file ", i, " of ", length(aligned_files), "\r", appendLF = (i == length(aligned_files)))
    aligned_data <- read.csv(paste0(filename))
    colnames(aligned_data)[1] <- "Frame"

    #Get information about current group
    groupID <- FilenameToGroup(filename)
    #Check to see if the group has changed, if it has then reset the count to 0
    if (is.null(old_groupID) || groupID != old_groupID) {
      count <- 0
      old_groupID <- groupID
    }

    res <- GetXY(
      XFinal, YFinal, aligned_data, final_summary,
      filtered, count, groupID, filename, do_filter)
    XFinal <- res$X
    YFinal <- res$Y
    final_summary <- res$final_summary
    count <- res$count
    filtered <- res$filtered
  }
  if (do_filter) {
    write.csv(filtered, row.names = FALSE, file = paste0(DIAGNOSTICS_DIR, "Activity_Filter.csv"))
  }
  final_summary$Group <- as.character(final_summary$Group)
  bulk_full <- AssembleBulkData(XFinal, YFinal)
  bulk_full <- Unblind(bulk_full, groups, groups_blind, is_unblinded)
  final_summary <- Unblind(final_summary, groups, groups_blind, is_unblinded)

  # Save the bulk data
  write.csv(bulk_full, row.names = FALSE, file = paste0(RESULTS_DIR, "BulkData_Full.csv"))
  # For some strange reason, we need to read it back,
  #    otherwise the object "bulk_full" is incorrect.
  #    R is a bizarre language.
  bulk_full <- read.csv(paste0(RESULTS_DIR, "BulkData_Full.csv"))
  return(list("final_summary" = final_summary, "bulk_full" = bulk_full))
}

# Creates BulkData_Avg.csv
SummarizeBulkYData <- function(bulk_full) {
  # Summarize bulk data and write BulkData_Avg.csv
  bulk_avg <- dplyr::summarise(
    dplyr::group_by(bulk_full, Frame, Group, Timepoint, Flowspeed),
    n = n(), sdY = sd(Y), Y = mean(Y), seY = sdY / sqrt(n))
  write.csv(bulk_avg, row.names = FALSE, file = paste0(RESULTS_DIR, "BulkData_Avg.csv"))
  return(bulk_avg)
}

# Creates BulkData_Avg.csv (for combo data)
SummarizeBulkYDataCombos <- function(bulk_full, combos) {
  bulk_full_combo <- bulk_full
  bulk_full_combo$Group <- as.character(bulk_full_combo$Group)
  for (i in seq_len(length(combos))) {
    combo <- unlist(combos[i])
    for (j in seq_len(length(combo))) {
      bulk_full_combo[bulk_full_combo == combo[j]] <- stringi::stri_flatten(combo)
    }
  }
  combo_summary <- dplyr::summarise(
    dplyr::group_by(bulk_full_combo, Frame, Group, Timepoint, Flowspeed),
    n = n(), sdY = sd(Y), Y = mean(Y), seY = sdY / sqrt(n))
  write.csv(
    dplyr::summarise(
      dplyr::group_by(rbind(bulk_full, bulk_full_combo), Frame, Group, Timepoint, Flowspeed),
      n = n(), sdY = sd(Y), Y = mean(Y), seY = sdY / sqrt(n)
    ),
    row.names = FALSE, file = paste0(RESULTS_DIR, "BulkData_Avg.csv")
  )
  return(list("bulk_full_combo" = bulk_full_combo, "combo_summary" = combo_summary))
}

# Creates SummaryData_Avg.csv
CalculateSummaryAveraged <- function(summary_full) {
  # NOTE: if you plan on using abreviated column names, the full version must match the version in LTS_MAP
  # NOTE: sd is standard deviation
  # NOTE: se is standard error of the mean (see https://onlinestatbook.com/2/sampling_distributions/samp_dist_mean.html)
  summary_avg <- dplyr::summarise(dplyr::group_by(summary_full, Group, Timepoint, Flowspeed), n = n(),
    "Avg_YPosition [px]" = mean(as.numeric(Y)), sdY = sd(Y), seY = sdY / sqrt(n),
    "Distance [px]" = mean(as.numeric(D)), sdD = sd(D), seD = sdD / sqrt(n),
    "Activity [%]" = mean(as.numeric(A)), sdA = sd(A), seA = sdA / sqrt(n),
    "Flow-Adjusted Activity [%]" = mean(as.numeric(AFA)), sdAFA = sd(AFA), seAFA = sdAFA / sqrt(n),
    "Efficiency" = mean(as.numeric(E)), sdE = sd(E), seE = sdE / sqrt(n),
    "Swimming Against Flow [%]" = mean(as.numeric(Dr)), sdDr = sd(Dr), seDr = sdDr / sqrt(n),
    "Flow-Adjusted Swimming Against Flow [%]" = mean(as.numeric(DrFAE)),
      sdDrFAE = sd(DrFAE), seDrFAE = sdDrFAE / sqrt(n),
    "Burst Duration [frames]" = mean(as.numeric(L)), sdL = sd(L), seL = sdL / sqrt(n),
    "Burst Frequency [bursts/min]" = mean(as.numeric(F)), sdF = sd(F), seF = sdF / sqrt(n),
    "Burst Amplitude [pixels]" = mean(as.numeric(Amp)), sdAmp = sd(Amp), seAmp = sdAmp / sqrt(n),
    "Time in Y-Quadrant 1 [%]" = mean(as.numeric(TY1Q)), sdTY1Q = sd(TY1Q), seTY1Q = sdTY1Q / sqrt(n),
    "Time in Y-Quadrant 2 [%]" = mean(as.numeric(TY2Q)), sdTY2Q = sd(TY2Q), seTY2Q = sdTY2Q / sqrt(n),
    "Time in Y-Quadrant 3 [%]" = mean(as.numeric(TY3Q)), sdTY3Q = sd(TY3Q), seTY3Q = sdTY3Q / sqrt(n),
    "Time in Y-Quadrant 4 [%]" = mean(as.numeric(TY4Q)), sdTY4Q = sd(TY4Q), seTY4Q = sdTY4Q / sqrt(n))
  # Write with long column names
  write.csv(summary_avg, row.names = FALSE, file = paste0(RESULTS_DIR, "SummaryData_Avg.csv"))
  # Return with short column names
  colnames(summary_avg) <- LongColnamesToShortColnames(colnames(summary_avg))
  return(summary_avg)
}

# Creates SummaryData_Full.csv
SummarizeByGroupAndFlow <- function(bulk_full, final_summary, combos) {
  message("Assembling summary data...", "\r")
  Y <- as.data.frame(dplyr::summarise(dplyr::group_by(bulk_full, Group, ID, Timepoint, Flowspeed), Y = mean(Y)))
  Y <- Y[order(Y$Flowspeed), ]  
  final_summary <- final_summary[order(final_summary$Group), ]
  headings <- colnames(final_summary)
  #Extract column names from the file
  distance_cols <- grep(pattern = "D\\d+", headings, value = T)
  activity_cols <- grep(pattern = "A\\d+", headings, value = T)
  FA_activity_cols <- grep(pattern = "AFA\\d+", headings, value = T)
  efficiency_cols <- grep(pattern = "E\\d+", headings, value = T)
  direction_cols <- grep(pattern = "Dr\\d+", headings, value = T)
  FE_direction_cols <- grep(pattern = "DrFAE\\d+", headings, value = T)
  burst_duration_cols <- grep(pattern = "L\\d+", headings, value = T)
  burst_freq_cols <- grep(pattern = "F\\d+", headings, value = T)
  burst_amp_cols <- grep(pattern = "Amp\\d+", headings, value = T)
  y_quad_1_cols <- grep(pattern = "TY1Q\\d+", headings, value = T)
  y_quad_2_cols <- grep(pattern = "TY2Q\\d+", headings, value = T)
  y_quad_3_cols <- grep(pattern = "TY3Q\\d+", headings, value = T)
  y_quad_4_cols <- grep(pattern = "TY4Q\\d+", headings, value = T)
  summary_full <- as.data.frame(cbind(
    "Timepoint" = Y$Timepoint,
    "Group" = Y$Group,
    "Fish" = Y$ID,
    "Flowspeed" = Y$Flowspeed,
    "Avg_YPosition [px]" = Y$Y,
    "Distance [px]" = unlist(final_summary[, distance_cols], use.names = FALSE),
    "Activity [%]" = unlist(final_summary[, activity_cols], use.names = FALSE),
    "Flow-Adjusted Activity [%]" = unlist(final_summary[, FA_activity_cols], use.names = FALSE),
    "Efficiency" = unlist(final_summary[, efficiency_cols], use.names = FALSE),
    "Swimming Against Flow [%]" = unlist(final_summary[, direction_cols], use.names = FALSE),
    "Flow-Adjusted Swimming Against Flow [%]" = unlist(final_summary[, FE_direction_cols], use.names = FALSE),
    "Burst Duration [frames]" = unlist(final_summary[, burst_duration_cols], use.names = FALSE),
    "Burst Frequency [bursts/min]" = unlist(final_summary[, burst_freq_cols], use.names = FALSE),
    "Burst Amplitude [pixels]" = unlist(final_summary[, burst_amp_cols], use.names = FALSE),
    "Time in Y-Quadrant 1 [%]" = unlist(final_summary[, y_quad_1_cols], use.names = FALSE),
    "Time in Y-Quadrant 2 [%]" = unlist(final_summary[, y_quad_2_cols], use.names = FALSE),
    "Time in Y-Quadrant 3 [%]" = unlist(final_summary[, y_quad_3_cols], use.names = FALSE),
    "Time in Y-Quadrant 4 [%]" = unlist(final_summary[, y_quad_4_cols], use.names = FALSE)
  ))
  summary_full[5:length(summary_full)] <- sapply(summary_full[5:length(summary_full)], as.numeric)
  summary_full <- summary_full[order(as.integer(row.names(Y))), ]
  write.csv(summary_full, row.names = FALSE, file = paste0(RESULTS_DIR, "SummaryData_Full.csv"))

  #Make group combinations (if any)
  if (length(combos) > 0) {
    SumFinalCombo <- summary_full
    SumFinalCombo$Group <- as.character(SumFinalCombo$Group)
    for (i in seq_len(length(combos))) {
      combo <- unlist(combos[i])
      for (j in seq_len(length(combo))) {
        SumFinalCombo[SumFinalCombo == combo[j]] <- stringi::stri_flatten(combo)
      }
    }
    summary_full <- rbind(summary_full, SumFinalCombo)
  }

  colnames(summary_full) <- LongColnamesToShortColnames(colnames(summary_full))
  summary_full$Timepoint <- as.factor(summary_full$Timepoint)

  return(summary_full)
}

############ Plotting ############

PlotAllGroupsYData <- function(bulk_full, bulk_avg, summary_avg, timepoints) {
  #Make separate batches of plots for each timepoint present...
  #Make plots for position over time...
  p <- ggplot(data = bulk_full, aes(x = Frame, y = Y, colour = Group)) +
    DEFAULT_THEME_BLANK_X_TEXT +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    ylim(0, TUNNEL_LENGTH) +
    xlab("Time") + ylab("Position within swim tunnel")
  png(paste0(GRAPHS_DIR, "YPosition_Avg-SE.png"), width = 1500, height = 400 * nrow(timepoints))
  print(p +
    geom_ribbon(
      data = bulk_avg,
      aes(ymin = bulk_avg$Y - bulk_avg$seY, ymax = bulk_avg$Y + bulk_avg$seY, fill = Group),
      alpha = 0.5) +
    geom_line(data = bulk_avg, alpha = 1) +
    geom_vline(aes(xintercept = FLOW_0_ENDS), linetype = "dashed") +
    geom_vline(aes(xintercept = FLOW_10_ENDS), linetype = "dashed") +
    facet_grid(Timepoint ~ .))
  dev.off()
  png(paste0(GRAPHS_DIR, "YPosition_Avg.png"), width = 1500, height = 400 * nrow(timepoints))
  print(p + geom_line(data = bulk_avg, alpha = 1) +
    geom_vline(aes(xintercept = FLOW_0_ENDS), linetype = "dashed") +
    geom_vline(aes(xintercept = FLOW_10_ENDS), linetype = "dashed") +
    facet_grid(Timepoint ~ .))
  dev.off()
  #Make 1D density plot for all groups combined...
  png(paste0(GRAPHS_DIR, "YDensityPlot_combined.png"), width = 2000, height = 400 * nrow(timepoints))
  meanY <- summary_avg[, c("Group", "Timepoint", "Flowspeed", "Y")]
  colnames(meanY) <- c("Group", "Timepoint", "Flowspeed", "Y")
  print(ggplot(data = bulk_full, aes(x = Y, fill = Group)) +
    geom_density(alpha = 0.4) +
    geom_vline(
      data = meanY,
      aes(xintercept = Y, color = Group), linetype = "dashed") +
    scale_y_continuous(expand = c(0, 0)) +
    scale_x_continuous(expand = c(0, 0)) +
    xlim(0, TUNNEL_LENGTH) +
    facet_grid(Timepoint ~ Flowspeed))
    #facet_grid(Timepoint ~ Flowspeed, scales = "free_y"))
  dev.off()
}

PlotIndividualGroups <- function(bulk_full, summary_avg, timepoints) {
  #Make 1D/2D density plots and distance plot of each group at each timepoint seperately...
  for (l in seq_len(nrow(timepoints))) {
    bulk_timepoint <- bulk_full[which(bulk_full$Timepoint == as.character(timepoints[l, ])), ]
    groups <- data.frame(unique(bulk_timepoint$Group))
    group_filenames <- data.frame(gsub("/", "", unique(bulk_timepoint$Group)))
    for (i in seq_len(nrow(groups))) {
      group <- groups[i, 1]
      group_filename <- group_filenames[i, 1]
      group_timepoint <- bulk_timepoint[which(bulk_timepoint$Group == group), ]
      group_timepoint_meanY <- summary_avg[which(summary_avg$Group == group), c("Flowspeed", "Y")]
      colnames(group_timepoint_meanY) <- c("Flowspeed", "Mean")
      p <- ggplot(data = group_timepoint, aes(x = Frame, y = Y, colour = Group)) +
        DEFAULT_THEME_BLANK_X_TEXT +
        scale_x_continuous(expand = c(0, 0)) +
        ylim(0, TUNNEL_LENGTH) +
        xlab("Time") +
        ylab("Position within swim tunnel")
      png(paste0(GROUPS_DIR, timepoints[l, ], "_", group_filename, "_YPosition.png"), width = 1500, height = 500)
      print(p + ggplot2::geom_line(ggplot2::aes(group = ID)))
      dev.off()
      png(paste0(GROUPS_DIR, timepoints[l, ], "_", group_filename, "_XYDensityPlot.png"), width = 900, height = 1000)
      print(ggplot(data = group_timepoint, aes(x = X, y = Y)) +
        stat_density_2d(aes(fill = ..density..), geom = "raster", contour = FALSE) +
        scale_x_reverse(limits = c(max(bulk_full$X), 0), expand = c(0, 0)) +
        scale_y_continuous(limits = c(0, max(bulk_full$Y)), expand = c(0, 0)) +
        scale_fill_distiller(oob = squish, palette = "Spectral", direction = -1, limits = c(0, 1.0e-05)) +
        ylim(0, TUNNEL_LENGTH) +
        facet_grid(. ~ Flowspeed))
      dev.off()
      png(paste0(GROUPS_DIR, timepoints[l, ], "_", group_filename, "_YDensityPlot.png"), width = 900, height = 1000)
      print(ggplot(data = group_timepoint, aes(x = Y)) +
        geom_density(alpha = 0.4) +
        geom_vline(data = group_timepoint_meanY, aes(xintercept = Mean), linetype = "dashed") +
        scale_y_continuous(expand = c(0, 0)) +
        scale_x_continuous(limits = c(0, max(bulk_full$Y)), expand = c(0, 0)) +
        xlim(0, TUNNEL_LENGTH) +
        coord_flip() +
        facet_grid(. ~ Flowspeed, scales = "free_x"))
      dev.off()
    }
  }
}

PlotIndividualFish <- function(bulk_full, summary_full, individuals) {
  #Make 1D/2D density plots for each individual fish seperately...
  for (i in seq_len(nrow(individuals))) {
    fishID <- as.character(individuals[i, 1])
    individual_data <- bulk_full[which(bulk_full$ID == fishID), ]
    individual_summary <- summary_full[which(summary_full$Fish == fishID), ]
    p <- ggplot(data = individual_data, aes(x = Frame, y = Y, colour = Group)) +
      DEFAULT_THEME +
      scale_x_continuous(expand = c(0, 0)) +
      ylim(0, TUNNEL_LENGTH) +
      xlab("Time") +
      ylab("Position within swim tunnel")
    png(paste0(INDIVIDUALS_DIR, individuals[i, 1], "_YPosition_Individual.png"), width = 1500, height = 500)
    print(p + ggplot2::geom_line(ggplot2::aes(group = ID)))
    dev.off()
    png(paste0(INDIVIDUALS_DIR, individuals[i, 1], "_XYDensityPlot.png"), width = 900, height = 1000)
    print(ggplot(data = individual_data, aes(x = X, y = Y)) +
      stat_density_2d(aes(fill = ..density..), geom = "raster", contour = FALSE) +
      scale_x_reverse(limits = c(max(bulk_full$X), 0), expand = c(0, 0)) +
      scale_y_continuous(limits = c(0, max(bulk_full$Y)), expand = c(0, 0)) +
      scale_fill_distiller(oob = squish, palette = "Spectral", direction = -1, limits = c(0, 1.0e-05)) +
      ylim(0, TUNNEL_LENGTH) +
      facet_grid(. ~ Flowspeed))
    dev.off()
    png(paste0(INDIVIDUALS_DIR, individuals[i, 1], "_YDensityPlot.png"), width = 900, height = 1000)
    meanY <- individual_summary[, c("Flowspeed", "Y")]
    colnames(meanY) <- c("Flowspeed", "Mean")
    print(ggplot(data = individual_data, aes(x = Y)) +
      geom_density(alpha = 0.4) +
      geom_vline(
        data = meanY,
        aes(xintercept = Mean), linetype = "dashed") +
      xlim(0, TUNNEL_LENGTH) +
      coord_flip() +
      scale_y_continuous(expand = c(0, 0)) +
      scale_x_continuous(limits = c(0, max(bulk_full$Y)), expand = c(0, 0)) +
      facet_grid(. ~ Flowspeed))
    dev.off()
  }
}

PlotComboVisualizations <- function(bulk_full, summary_avg, timepoints, bulk_full_combo, combo_summary) {
  #Make separate batches of plots for each timepoint present...
  for (l in seq_len(nrow(timepoints))) {
    #Make plots for position over time...
    bulk_combo_timepoint <- bulk_full_combo[which(bulk_full$Timepoint == as.character(timepoints[l, ])), ]
    combo_summary_timepoint <- combo_summary[which(combo_summary$Timepoint == as.character(timepoints[l, ])), ]
    p <- ggplot(data = bulk_combo_timepoint, aes(x = Frame, y = Y, colour = Group)) +
      DEFAULT_THEME_BLANK_X_TEXT +
      scale_x_continuous(limits = c(1, nrow(bulk_full)), expand = c(0, 0)) +
      ylim(0, TUNNEL_LENGTH) +
      xlab("Time") +
      ylab("Position within swim tunnel")
    png(paste0(GRAPHS_DIR, "YPosition_Avg-SE_combo.png"), width = 1500, height = 400 * nrow(timepoints))
    print(p + geom_ribbon(
      data = combo_summary_timepoint,
      aes(
        ymin = combo_summary_timepoint$Y - combo_summary_timepoint$seY,
        ymax = combo_summary_timepoint$Y + combo_summary_timepoint$seY,
        fill = Group),
      alpha = 0.5) +
      geom_line(data = combo_summary_timepoint, alpha = 1) +
      geom_vline(aes(xintercept = FLOW_0_ENDS), linetype = "dashed") +
      geom_vline(aes(xintercept = FLOW_10_ENDS), linetype = "dashed") +
      xlim(0, TUNNEL_LENGTH) +
      facet_grid(Timepoint ~ .))
    dev.off()
    #Make 1D density plot for all groups combined...
    png(paste0(GRAPHS_DIR, "YDensityPlot_combined_combo.png"), width = 2000, height = 400 * length(timepoints))
    meanY <- summary_avg[
      summary_avg$Group %in% unique(bulk_combo_timepoint$Group),
      c("Group", "Flowspeed", "Y")]
    colnames(meanY) <- c("Group", "Flowspeed", "Y")
    print(ggplot(data = bulk_combo_timepoint, aes(x = Y, fill = Group)) +
      geom_density(alpha = 0.4) +
        geom_vline(
          data = meanY,
          aes(xintercept = Y, color = Group), linetype = "dashed") +
        xlim(0, TUNNEL_LENGTH) +
        scale_y_continuous(expand = c(0, 0)) +
        scale_x_continuous(limits = c(0, max(bulk_full$Y)), expand = c(0, 0)) +
        facet_grid(Timepoint ~ Flowspeed))
    dev.off()

    #Make 1D/2D density plots of each group seperately...
    groups <- data.frame(unique(bulk_combo_timepoint$Group))
    group_filenames <- data.frame(gsub("/", "", unique(bulk_combo_timepoint$Group)))
    for (i in seq_len(nrow(groups))) {
      temp <- bulk_combo_timepoint[which(bulk_combo_timepoint$Group == groups[i, 1]), ]
      combo_summary_timepoint <- dplyr::summarise(dplyr::group_by(temp, Flowspeed), Mean = mean(Y))
      png(paste0(GROUPS_DIR, group_filenames[i, 1], "_XYDensityPlot.png"), width = 900, height = 1000)
      print(ggplot(data = temp, aes(x = X, y = Y)) +
            stat_density_2d(aes(fill = ..density..), geom = "raster", contour = FALSE) +
            scale_x_reverse(limits = c(max(bulk_full$X), 0), expand = c(0, 0)) +
            scale_y_continuous(limits = c(0, max(bulk_full$Y)), expand = c(0, 0)) +
            scale_fill_distiller(oob = squish, palette = "Spectral", direction = -1, limits = c(0, 1.0e-05)) +
            ylim(0, TUNNEL_LENGTH) +
            facet_grid(. ~ Flowspeed))
      dev.off()
      png(paste0(GROUPS_DIR, group_filenames[i, 1], "_YDensityPlot.png"), width = 900, height = 1000)
      print(ggplot(data = temp, aes(x = Y)) +
            geom_density(alpha = 0.4) +
            geom_vline(data = combo_summary_timepoint, aes(xintercept = Mean), linetype = "dashed") +
            scale_y_continuous(expand = c(0, 0)) +
            scale_x_continuous(expand = c(0, max(bulk_full$Y))) +
            xlim(0, TUNNEL_LENGTH) +
            coord_flip() +
            facet_grid(. ~ Flowspeed))
      dev.off()
    }
  }
}

PlotSummary <- function(summary_avg, timepoints) {
  SaveSummaryPNG <- function(png_filename) {
    png(
      paste0(GRAPHS_DIR, png_filename),
      width = 100 + (30 * length(unique(summary_avg$Group)) * nrow(timepoints)), height = 1000)
  }
  default_plot <- ggplot(data = summary_avg, aes(x = Timepoint, fill = Group)) +
    scale_y_continuous(expand = c(0, 0)) +
    theme_classic() +
    DEFAULT_THEME +
    facet_grid(Flowspeed ~ .)
  DefaultGeomBar <- function(aes_to_use) {
    return(ggplot2::geom_bar(aes_to_use, position = "dodge", stat = "identity", color = "black"))
  }
  DefaultErrorBar <- function(aes_to_use) {
    return(ggplot2::geom_errorbar(aes_to_use, width = .2, position = ggplot2::position_dodge(.9)))
  }
  ##Plot summary data...
  message("Plotting data summarized by group...", "\r")
  SaveSummaryPNG("Summary_Activity.png")
  print(default_plot + DefaultGeomBar(aes(y = A)) +
    DefaultErrorBar(aes(ymin = A - seA, ymax = A + seA)) +
    ylab("% Activity") +
    ylim(0, 100))
  dev.off()
  SaveSummaryPNG("Summary_ActivityFlowAdjusted.png")
  print(default_plot + DefaultGeomBar(aes(y = AFA)) +
    DefaultErrorBar(aes(ymin = AFA - seAFA, ymax = AFA + seAFA)) +
    ylab("% Activity") +
    ylim(0, 100))
  dev.off()
  SaveSummaryPNG("Summary_Distance.png")
  print(default_plot + DefaultGeomBar(aes(y = D)) +
    DefaultErrorBar(aes(ymin = D - seD, ymax = D + seD)) +
    ylab("Distance Swam (px)"))
  dev.off()
  SaveSummaryPNG("Summary_YPosition.png")
  print(default_plot + DefaultGeomBar(aes(y = Y)) +
    DefaultErrorBar(aes(ymin = Y - seY, ymax = Y + seY)) +
    ylim(0, TUNNEL_LENGTH) +
    ylab("Average Y Position in Swim Tunnel"))
  dev.off()
  SaveSummaryPNG("Summary_Direction.png")
  print(default_plot + DefaultGeomBar(aes(y = Dr)) +
    DefaultErrorBar(aes(ymin = Dr - seDr, ymax = Dr + seDr)) +
    ylab("Time Swimming Against Flow (%)") + 
    ylim(0, 100))
  dev.off()
  SaveSummaryPNG("Summary_DirectionFlowAdjusted.png")
  print(default_plot + DefaultGeomBar(aes(y = DrFAE)) +
    DefaultErrorBar(aes(ymin = DrFAE - seDrFAE, ymax = DrFAE + seDrFAE)) +
    ylab("Time Swimming Against Flow (%)") +
    ylim(0, 100))
  dev.off()
  SaveSummaryPNG("Summary_BurstDuration.png")
  print(default_plot + DefaultGeomBar(aes(y = L)) +
    DefaultErrorBar(aes(ymin = L - seL, ymax = L + seL)) +
    ylab("Burst Duration [frames]"))
  dev.off()
  SaveSummaryPNG("Summary_BurstFrequency.png")
  print(default_plot + DefaultGeomBar(aes(y = F)) +
    DefaultErrorBar(aes(ymin = F - seF, ymax = F + seF)) +
    ylab("Burst Frequency [burst/min]"))
  dev.off()
  SaveSummaryPNG("Summary_BurstAmplitude.png")
  print(default_plot + DefaultGeomBar(aes(y = Amp)) +
    DefaultErrorBar(aes(ymin = Amp - seAmp, ymax = Amp + seAmp)) +
    ylab("Burst Amplitude [px]"))
  dev.off()

  # New in V7
  # Plot Y Quadrant Summaries
  for (i in c(seq_len(4))) {
    SaveSummaryPNG(paste0("Summary_YQuadrant", i, ".png"))
    print(default_plot + DefaultGeomBar(aes(y = eval(as.name(paste0("TY", i, "Q"))))) +
      DefaultErrorBar(aes(
        ymin = eval(as.name(paste0("TY", i, "Q"))) - eval(as.name(paste0("seTY", i, "Q"))),
        ymax = eval(as.name(paste0("TY", i, "Q"))) + eval(as.name(paste0("seTY", i, "Q")))
      )) + ylab(paste0("% Time Spent in Y Quadrant ", i)) +
        ylim(0, 100))
    dev.off()
  }
}

############ Main ############

main <- function() {
  # Defines the main flow.
  # Any major features should be functions which are called here.
  setup_result <- Setup()
  groups <- setup_result$groups
  groups_blind <- setup_result$groups_blind
  file_patterns_to_align <- setup_result$file_patterns_to_align
  is_unblinded <- setup_result$is_unblinded
  do_filter <- setup_result$do_filter
  combos <- setup_result$combos

  AlignData(file_patterns_to_align, groups)
  metrics_result <- CalculateSwimMetrics(groups, groups_blind, is_unblinded, do_filter)
  final_summary <- metrics_result$final_summary
  bulk_full <- metrics_result$bulk_full
  bulk_avg <- SummarizeBulkYData(bulk_full)
  individuals <- data.frame(unique(bulk_full$ID))
  timepoints <- data.frame(unique(bulk_full$Timepoint))
  summary_full <- SummarizeByGroupAndFlow(bulk_full, final_summary, combos)
  summary_avg <- CalculateSummaryAveraged(summary_full)

  ##VISUALIZING THE DATA##
  #Plot the bulk data...
  message("Plotting bulk data...", "\r")
  #Make graphs for the group combinations (if any) specified at the beginning
  if (length(combos) > 0) {
    combo_result <- SummarizeBulkYDataCombos(bulk_full, combos)
    PlotComboVisualizations(
      bulk_full,
      summary_avg,
      timepoints,
      combo_result$bulk_full_combo,
      combo_result$combo_summary)
  }
  PlotSummary(summary_avg, timepoints)
  PlotAllGroupsYData(bulk_full, bulk_avg, summary_avg, timepoints)
  PlotIndividualFish(bulk_full, summary_full, individuals)
  PlotIndividualGroups(bulk_full, summary_avg, timepoints)
}

main()
