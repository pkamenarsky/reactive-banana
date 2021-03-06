{-----------------------------------------------------------------------------
    reactive-banana
------------------------------------------------------------------------------}
{-# LANGUAGE Rank2Types, BangPatterns, RecordWildCards #-}
module Reactive.Banana.Prim.Order (
    -- * Synopsis
    -- | Data structure that represents a partial ordering by levels.
    
    -- * Order
    Order, flat,
    ensureAbove, recalculateParent,
    Level, level,
    
    ) where

import qualified Data.Map.Strict     as Map
import qualified Data.Set            as Set

type Map    = Map.Map

{-----------------------------------------------------------------------------
    Order by levels
------------------------------------------------------------------------------}
-- | Each element is assigned a /level/.
-- Elements in lower levels come before elements in higher levels.
-- There is no order on elements within the same level.
type Order a = Map a Level

-- | FIXME: Level should be an 'Integer' to avoid overflow.
--
-- FIXME: The algorithms in this module currently do not try to
-- shrink the number or width of levels.
type Level   = Integer

-- | The flat order where every element is at 'ground' level.
flat :: Order a
flat = Map.empty

-- | Ground level.
ground :: Level
ground = 0

-- | Look up the level of an element. Default level is 'ground'.
level :: Ord a => a -> Order a -> Level
level x = {-# SCC level #-} maybe ground id . Map.lookup x

-- | Make sure that the first argument is at least one level
-- above the second argument.
ensureAbove :: Ord a => a -> a -> Order a -> Order a
ensureAbove child parent order =
    Map.insertWith max child (level parent order + 1) order

-- | Reassign the parent for a child and recalculate the levels
-- for the new parents and grandparents.
recalculateParent :: Ord a
    => a       -- Child.
    -> a       -- Parent.
    -> Graph a -- Query parents of a node. 
    -> Order a -> Order a
recalculateParent child parent parents order
    | d <= 0    = order
    | otherwise = concatenate
        [ Map.insertWith (+) node (-d) | node <- dfs parent parents ]
        order
    where
    d = level parent order - level child order + 1
    -- level parent - d = level child - 1
    concatenate = foldr (.) id

{-----------------------------------------------------------------------------
    Graph traversal
------------------------------------------------------------------------------}
-- | Graph represented as map of successors.
type Graph a = a -> [a]

-- | Depth-first search. List all transitive successors of a node.
dfs :: Ord a => a -> Graph a -> [a]
dfs x succs = go [x] Set.empty
    where
    go []     _               = []
    go (x:xs) seen
        | x `Set.member` seen = go xs seen
        | otherwise           = x : go (ys ++ xs) (Set.insert x seen)
        where
        ys = succs x
