package app.meldeplanner.android.ui.navigation

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.meldeplanner.android.ui.components.rememberReduceMotion
import app.meldeplanner.android.ui.components.sfSymbol
import app.meldeplanner.android.ui.theme.meldoChrome
import app.meldeplanner.android.ui.theme.meldoHairline

/** Height of the floating tab bar, expanded and while minimized on scroll. */
val TabBarHeight = 64.dp
private val TabBarMinimizedHeight = 48.dp

/** Space between the tab bar and the screen edges. */
val TabBarMargin = 16.dp

/** One tab of the [FloatingTabBar]. */
class TabItem(val title: String, val symbol: String, val selected: Boolean, val onClick: () -> Unit)

/**
 * The iOS 26 tab bar on Android: a floating frosted capsule instead of a flat strip
 * along the bottom. A tonal lens slides to the selected tab with the theme's spring.
 * While content scrolls down the bar minimizes (labels fold away), like
 * `tabBarMinimizeBehavior(.onScrollDown)`; scrolling up brings them back.
 */
@Composable
fun FloatingTabBar(items: List<TabItem>, minimized: Boolean, modifier: Modifier = Modifier) {
    val reduceMotion = rememberReduceMotion()
    val motion = MaterialTheme.motionScheme
    val height by animateDpAsState(
        if (minimized) TabBarMinimizedHeight else TabBarHeight,
        if (reduceMotion) androidx.compose.animation.core.snap() else motion.defaultSpatialSpec(),
        label = "tabBarHeight",
    )
    BoxWithConstraints(
        modifier
            .fillMaxWidth()
            .height(height)
            // Soft contact shadow under the floating capsule; the hairline carries the edge.
            .shadow(18.dp, CircleShape, ambientColor = Color.Black.copy(alpha = 0.35f), spotColor = Color.Black.copy(alpha = 0.45f))
            .clip(CircleShape)
            .meldoChrome()
            .border(meldoHairline(), CircleShape)
            .selectableGroup(),
    ) {
        val count = items.size.coerceAtLeast(1)
        val itemWidth = maxWidth / count
        val index = items.indexOfFirst { it.selected }.coerceAtLeast(0)
        val lensX by animateDpAsState(
            itemWidth * index,
            if (reduceMotion) androidx.compose.animation.core.snap() else motion.defaultSpatialSpec(),
            label = "tabLens",
        )
        // The lens behind the selected tab.
        Box(
            Modifier
                .offset(x = lensX)
                .width(itemWidth)
                .fillMaxHeight()
                .padding(5.dp)
                .background(MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.85f), CircleShape),
        )
        Row(Modifier.fillMaxWidth().fillMaxHeight()) {
            items.forEach { item ->
                TabButton(item, minimized, Modifier.weight(1f).fillMaxHeight())
            }
        }
    }
}

@Composable
private fun TabButton(item: TabItem, minimized: Boolean, modifier: Modifier) {
    val color = if (item.selected) MaterialTheme.colorScheme.onSecondaryContainer else MaterialTheme.colorScheme.onSurfaceVariant
    Column(
        modifier
            .clip(CircleShape)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(bounded = true),
                onClick = item.onClick,
            )
            .semantics {
                role = Role.Tab
                selected = item.selected
            },
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(sfSymbol(item.symbol), contentDescription = if (minimized) item.title else null, tint = color, modifier = Modifier.size(24.dp))
        AnimatedVisibility(
            visible = !minimized,
            enter = fadeIn() + expandVertically(),
            exit = fadeOut() + shrinkVertically(),
        ) {
            Text(
                item.title,
                color = color,
                maxLines = 1,
                softWrap = false,
                textAlign = TextAlign.Center,
                // Fits "Stundenplan" and the longer Turkish labels in a fifth of the bar.
                autoSize = androidx.compose.foundation.text.TextAutoSize.StepBased(minFontSize = 8.sp, maxFontSize = 11.sp),
                style = TextStyle(fontWeight = if (item.selected) FontWeight.SemiBold else FontWeight.Medium, fontSize = 11.sp),
                modifier = Modifier.padding(horizontal = 2.dp, vertical = 0.dp),
            )
        }
    }
}

/**
 * Watches the scrolling inside the tabs: minimized after scrolling down a little,
 * expanded again as soon as the content scrolls up.
 */
class TabBarScrollState : NestedScrollConnection {
    var minimized by mutableStateOf(false)
        private set
    private var travel by mutableFloatStateOf(0f)

    override fun onPostScroll(consumed: Offset, available: Offset, source: NestedScrollSource): Offset {
        val dy = consumed.y
        if (dy < 0f) {
            travel = (travel + -dy).coerceAtMost(200f)
            if (travel > 48f) minimized = true
        } else if (dy > 0f || available.y > 0f) {
            travel = 0f
            minimized = false
        }
        return Offset.Zero
    }

    fun expand() {
        travel = 0f
        minimized = false
    }
}
